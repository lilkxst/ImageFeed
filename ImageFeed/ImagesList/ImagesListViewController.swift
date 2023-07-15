//
//  ViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 27.04.23.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService()
    private var imageListServiceObserver: NSObjectProtocol?
    private (set) var photos: [Photo] = []
    
    override func viewDidAppear(_ animated: Bool) {
        imageListService.fetchPhotosNextPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImageListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                updateTableViewAnimated()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath {
            let singleImageURL = imageListService.photos[indexPath.row].largeImageURL
            viewController.singleImageURL = singleImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    func convertDate(dateValue: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dateValue)
        if let date = date {
            return date
        } else {
            return Date()
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = imageListService.photos[indexPath.row]
        let photoUrl = photo.thumbImageURL
        guard let url = URL(string: photoUrl) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.contentMode = .center
        cell.isUserInteractionEnabled = false
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "stubImage")) { result in
            switch result {
            case .success:
                cell.cellImage.contentMode = .scaleAspectFill
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("Не удалось загрузить фотографию \(error)")
            }
            cell.isUserInteractionEnabled = true
        }
        
        guard let createdAt = photo.createdAt else { cell.dateLabel.text = ""; return }
        cell.dateLabel.text = dateFormatter.string(from: convertDate(dateValue: createdAt))
        
        setIsLiked(photo, cell)
    }
    
    private func setIsLiked(_ photo: Photo, _ cell: ImagesListCell) {
        let buttonState = photo.isLiked ? "activeLikeButton" : "noActiveLikeButton"
        cell.likeButton.setImage(UIImage(named: buttonState), for: .normal)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < imageListService.photos.count else { return 0 }
        
        let imageSize = imageListService.photos[indexPath.row].size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        if imageWidth == 0 { return 0 }
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPath = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPath, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    func imageLitsCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success:
                self.photos[indexPath.row].isLiked = self.imageListService.photos[indexPath.row].isLiked
                self.setIsLiked(self.photos[indexPath.row], cell)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Ошибка: \(error)")
            }
        }
    }
}
