//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 15.05.23.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    private var nameLabel: UILabel!
    private var linkLabel: UILabel!
    private var descriptionLabel: UILabel!
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createProfileView()
        updateProfileDetails(profile: profileService.profile!)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
            }
        updateAvatar()
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
        logautButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        logautButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logautButton)
        logautButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logautButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 53).isActive = true
        logautButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logautButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name ?? ""
        linkLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let imageView = view.viewWithTag(1) as? UIImageView
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
    
    @objc
    
    func didTapLogautButton() {
        
    }
}
