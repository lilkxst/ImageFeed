//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 7.06.23.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token)
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func showAlert() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(alertButton)
        present(alert, animated: true, completion: nil)
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
            case .success:
                self.profileImageService.fetchProfileImageURL(username: self.profileService.profile!.username) { imageResult in
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
