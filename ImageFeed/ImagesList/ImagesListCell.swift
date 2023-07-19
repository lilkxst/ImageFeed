//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Артём Костянко on 5.05.23.
//

import Foundation
import UIKit

protocol ImageListCellDelegate: AnyObject {
    func imageLitsCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: ImageListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageLitsCellDidTapLike(self)
    }
}
