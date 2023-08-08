//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Артём Костянко on 24.07.23.
//

import WebKit
import Kingfisher
import UIKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func updateProfileDetails()
    func logOut()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    var profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        self.updateAvatar()
        self.updateProfileDetails()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let imageView = self.view?.view.viewWithTag(1) as? UIImageView
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: imageView.frame.width / 2)
        let placeholderImage = UIImage(named: "ProfileImagePlaceholder")
        imageView.kf.setImage(with: url, placeholder: placeholderImage, options: [.processor(processor)], completionHandler: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(_):
                print("Фото загружено")
            case .failure(let error):
                print("Фото не загружено: \(error)")
            }
        })
    }
    
    func updateProfileDetails() {
        guard let view = self.view else { return }
        view.descriptionLabel.text = profileService.profile?.bio ?? ""
        view.linkLabel.text = profileService.profile?.loginName
        view.nameLabel.text = profileService.profile?.name ?? ""
    }
    
    func logOut() {
        OAuth2TokenStorage.shared.removeToken()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
           WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
              records.forEach { record in
                 WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
              }
           }
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
}
