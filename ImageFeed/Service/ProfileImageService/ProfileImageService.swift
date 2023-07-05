//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Артём Костянко on 30.06.23.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String?, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        var profileImageRequest: URLRequest {
            URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET", tokenIsNeeded: true)
        }
        let task = urlSession.objectTask(for: profileImageRequest) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    self.avatarURL = body.profileImage.small
                    completion(.success(self.avatarURL))
                    NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.avatarURL ?? ""])
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
}
