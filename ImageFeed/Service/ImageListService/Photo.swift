//
//  Photo.swift
//  ImageFeed
//
//  Created by Артём Костянко on 7.07.23.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
