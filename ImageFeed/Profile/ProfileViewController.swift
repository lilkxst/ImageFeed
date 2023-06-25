//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 15.05.23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createProfileView()
    }
    
    func createProfileView() {
        let profileImage = UIImage(named: "ProfileImage")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = nameLabel.font.withSize(23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        let linkLabel = UILabel()
        linkLabel.text = "@ekaterina_nov"
        linkLabel.textColor = .gray
        linkLabel.font = linkLabel.font.withSize(13)
        linkLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(linkLabel)
        linkLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        linkLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        let descriptionLabel = UILabel()
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
    
    @objc
    
    func didTapLogautButton() {
        
    }
}
