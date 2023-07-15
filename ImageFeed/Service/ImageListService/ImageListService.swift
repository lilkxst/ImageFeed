//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Артём Костянко on 7.07.23.
//

import Foundation

final class ImageListService {
    private var lastLoadedPage: Int?
    private (set) var photos: [Photo] = []
    private var pageTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private let urlSession = URLSession.shared
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    static let shared = ImageListService()
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if pageTask != nil {
            pageTask?.cancel()
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        let photosPageRequest = URLRequest.makeHTTPRequest(path: "/photos?page=\(nextPage)&&per_page=10", httpMethod: "GET", tokenIsNeeded: true)
        let task = urlSession.objectTask(for: photosPageRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    self.photos += body.map {
                        Photo(id: $0.id,
                              size: CGSize(width: $0.width, height: $0.height),
                              createdAt: $0.createdAt,
                              welcomeDescription: $0.description,
                              thumbImageURL: $0.urls.thumb ?? "",
                              largeImageURL: $0.urls.full ?? "",
                              isLiked: $0.isLiked)
                    }
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: self, userInfo: ["photos": self.photos])
                    print("Запрос совершен")
                    self.lastLoadedPage = nextPage
                    self.pageTask = nil
                case .failure(let error):
                    print("Ошибка загрузки фото \(error)")
                    self.pageTask = nil
                }
            }
        }
        self.pageTask = nil
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        likeTask?.cancel()
        let httpMethod = isLike ? "DELETE" : "POST"
        let likeRequest = URLRequest.makeHTTPRequest(path: "photos/\(photoId)/like", httpMethod: httpMethod, tokenIsNeeded: true)
        let likeTask = urlSession.objectTask(for: likeRequest) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let likeResult):
                    let photoId = likeResult.photo.id
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLiked = likeResult.photo.isLiked
                    }
                    completion(.success(()))
                    self.likeTask = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.likeTask = nil
                }
            }
        }
        self.likeTask = likeTask
        likeTask.resume()
    }
}
