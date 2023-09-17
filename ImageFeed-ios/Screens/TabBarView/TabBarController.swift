//
//  TabBarController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 01.09.2023.
//

import UIKit

// MARK: - Class

final class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBarView()
    setupTabBarViewController()
  }
}

// MARK: - Private methods to setup UI

private extension TabBarController {

  func setupTabBarView() {
    tabBar.barStyle = .black
    tabBar.tintColor = .ypWhite
    tabBar.backgroundColor = .ypBlack // use this to make tabBar black, not translucent
  }

  func setupTabBarViewController() {
    view.backgroundColor = .ypBackground

    let storyboard = UIStoryboard(name: "Main", bundle: .main)

    let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")

    let profileViewController = ProfileViewController()
    setupTabBarItem(for: profileViewController, image: "tab_profile_active")

    viewControllers = [imagesListViewController, profileViewController]
    selectedIndex = 0
  }

  func setupTabBarItem(for viewController: UIViewController, image: String) {
    viewController.tabBarItem = UITabBarItem(
      title: nil,
      image: UIImage(named: image),
      selectedImage: nil
    )
  }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    selectedViewController = viewController
  }
}
