//
//  RootNavigationController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 16.08.2023.
//

import UIKit

final class RootNavigationController: UINavigationController {
  // Return the visible child view controller which determines the status bar style.
  override var childForStatusBarStyle: UIViewController? {
    return visibleViewController
  }
}
