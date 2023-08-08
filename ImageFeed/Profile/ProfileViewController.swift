//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 15.05.23.
//

import UIKit
import Kingfisher
import WebKit

protocol ProfileViewControllerProtocol: UIViewController {
    var presenter: ProfileViewPresenterProtocol { get set }
    var nameLabel: UILabel! { get set }
    var linkLabel: UILabel! { get set }
    var descriptionLabel: UILabel! { get set }
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {

    var presenter: ProfileViewPresenterProtocol = ProfileViewPresenter()
    var nameLabel: UILabel!
    var linkLabel: UILabel!
    var descriptionLabel: UILabel!
    private let profileService = ProfileService.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(presenter)
        createProfileView()
        presenter.viewDidLoad()
    }
    
    func createProfileView() {
        view.backgroundColor = UIColor(named: "YP Black")
        let profileImage = UIImage(named: "ProfileImagePlaceholder")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.tag = 1
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = nameLabel.font.withSize(23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        linkLabel = UILabel()
        linkLabel.text = "@ekaterina_nov"
        linkLabel.textColor = .gray
        linkLabel.font = linkLabel.font.withSize(13)
        linkLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(linkLabel)
        linkLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        linkLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = descriptionLabel.font.withSize(13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: linkLabel.bottomAnchor, constant: 8).isActive = true
        
        let logautButton = UIButton.systemButton(with: UIImage(imageLiteralResourceName: "ProfileLogaut"), target: self, action: #selector(self.didTapLogautButton))
        logautButton.accessibilityIdentifier = "logoutButton"
        logautButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        logautButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logautButton)
        logautButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logautButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 53).isActive = true
        logautButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logautButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    @objc
    
    private func didTapLogautButton() {
        showAlert()
    }
    
   private func showAlert() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        
       alert.addAction(UIAlertAction(title: "Да", style: .default) { _ in
           self.presenter.logOut()
          })
        
        present(alert, animated: true)
    }
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
            self.presenter = presenter
            self.presenter.view = self
        }
}
