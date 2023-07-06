//
//  UserResult.swift
//  ImageFeed
//
//  Created by Артём Костянко on 30.06.23.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}
