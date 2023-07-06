//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 4.07.23.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController")
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tabProfileActive"),
            selectedImage: nil)
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
