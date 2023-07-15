//
//  PhototResult.swift
//  ImageFeed
//
//  Created by Артём Костянко on 7.07.23.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlResult
    let isLiked: Bool
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case isLiked = "liked_by_user"
    }
    
}

struct UrlResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

struct LikeResult: Codable {
    let photo: PhotoResult
}
