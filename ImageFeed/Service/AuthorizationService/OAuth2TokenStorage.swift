//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Артём Костянко on 11.06.23.
//

import Foundation

class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
