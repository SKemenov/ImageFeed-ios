//
//  TabBarController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 01.09.2023.
//

import UIKit

final class TabBarController: UITabBarController {

  override func awakeFromNib() {
    super.awakeFromNib()

    let storyboard = UIStoryboard(name: "Main", bundle: .main)

    let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")

    let profileViewController = ProfileViewController()
    setupTabBarItem(for: profileViewController, image: "tab_profile_active")

    self.viewControllers = [imagesListViewController, profileViewController]
  }
}

private extension TabBarController {
  func setupTabBarItem(for viewController: ProfileViewController, image: String) {
    viewController.tabBarItem = UITabBarItem(
      title: nil,
      image: UIImage(named: image),
      selectedImage: nil
    )
  }
}
