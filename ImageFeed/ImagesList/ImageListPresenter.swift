//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Артём Костянко on 25.07.23.
//

import Foundation

protocol ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get set }
    func viewDidLoad()
    func viewDidAppear()
    func changeNotification()
    func changeLike(_ index: Int, _ cell: ImagesListCell)
}

final class ImageListPresenter: ImageListPresenterProtocol {
    
    weak var view: ImageListViewControllerProtocol?
    private let imageListService = ImageListService()
    private var imageListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    func viewDidLoad() {
        changeNotification()
    }
    
    func viewDidAppear() {
        imageListService.fetchPhotosNextPage()
    }
    
    func changeNotification() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImageListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                view?.updateTableViewAnimated()
            }
    }
    
    func changeLike(_ index: Int, _ cell: ImagesListCell) {
        let photo = photos[index]
        imageListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success:
                self.photos[index].isLiked = self.imageListService.photos[index].isLiked
                self.view?.setIsLiked(self.photos[index], cell)
            case .failure(let error):
                print("Ошибка: \(error)")
            }
        }
    }
}
