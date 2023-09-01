//
//  RootNavigationController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 16.08.2023.
//

import UIKit

final class RootNavigationController: UINavigationController {
  override var childForStatusBarStyle: UIViewController? {
    return visibleViewController
  }
}
