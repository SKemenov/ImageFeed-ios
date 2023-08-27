//
//  UIBlockingProgressHUD.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 27.08.2023.
//

import UIKit
import ProgressHUD

// swiftlint:disable:next convenience_type
final class UIBlockingProgressHUD {
  private static var window: UIWindow? {
    UIApplication.shared.windows.first
  }

  static func show() {
    window?.isUserInteractionEnabled = false
    ProgressHUD.animationType = .circleRotateChase
    ProgressHUD.colorHUD = .clear
    ProgressHUD.show()
  }

  static func dismiss() {
    window?.isUserInteractionEnabled = true
    ProgressHUD.dismiss()
  }
}
