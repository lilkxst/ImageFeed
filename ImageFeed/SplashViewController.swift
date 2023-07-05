//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 7.06.23.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSplashController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token)
        } else {
            UIBlockingProgressHUD.dismiss()
            showAuthViewController()
        }
    }
    
    private func createSplashController() {
        view.backgroundColor = UIColor(named: "YP Black")
        let screenLogoImage = UIImage(named: "ImageLaunchScreen")
        let screenLogoImageView = UIImageView(image: screenLogoImage)
        screenLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(screenLogoImageView)
        screenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        screenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        screenLogoImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        screenLogoImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(
            name: "Main",
            bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    private func showAlert() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(alertButton)
        present(alert, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

extension SplashViewController {
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success:
                        print("Ссылка передана")
                    case .failure:
                        print("Ошибка передачи")
                    }
                }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                self.showAlert()
            }
        }
    }
}
