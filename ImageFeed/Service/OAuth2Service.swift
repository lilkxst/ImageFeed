//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Артём Костянко on 7.06.23.
//

import Foundation

fileprivate var apiUnsplashURL: URL {
    guard let url = URL(string: "https://api.unsplash.com") else {
        preconditionFailure("Unable to construct apiUnsplashURL")
    }
    return url
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue!
        }
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping ((Swift.Result<String, Error>) -> Void)) {
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey))"
            + "&&client_secret=\(secretKey)"
            + "&&redirect_uri=\(redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "http://unsplash.com")!
        )
    }
    
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) {
            (result: Result<Data, Error>) in
            let response = result.flatMap {
                data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
        
}
    
    extension URLRequest {
        static func makeHTTPRequest(path: String, httpMethod: String, baseURL: URL = apiUnsplashURL) -> URLRequest {
            var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
            request.httpMethod = httpMethod
            return request
        }
    }
    
    extension URLSession {
        func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
            let fullfillCompletion: (Result<Data, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            let task = dataTask(with: request, completionHandler: { data, response, error in
                if let data = data,
                   let response = response,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode
                {
                    if 200..<300 ~= statusCode {
                        fullfillCompletion(.success(data))
                    } else {
                        fullfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    fullfillCompletion(.failure(NetworkError.urlRequestError(error)))
                } else {
                    fullfillCompletion(.failure(NetworkError.urlSessionError))
                }
            } )
            task.resume()
            return task
        }
    }

