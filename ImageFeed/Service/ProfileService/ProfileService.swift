//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Артём Костянко on 28.06.23.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private (set) var profile: Profile?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        var profileRequest: URLRequest {
            URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET", tokenIsNeeded: true)
        }
        let task = object(for: profileRequest) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let profile = Profile(username: body.username, name: "\(body.firstName) \(body.lastName)", loginName: "@\(body.username)", bio: body.bio)
                    self.profile = profile
                    self.task = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.task = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func object(for request: URLRequest, completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) {
            (result: Result<Data, Error>) in
            let response = result.flatMap {
                data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
}
