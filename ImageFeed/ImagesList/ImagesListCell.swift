//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Артём Костянко on 5.05.23.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
}
