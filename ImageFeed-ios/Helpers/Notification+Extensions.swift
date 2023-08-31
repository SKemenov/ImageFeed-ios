//
//  Notification+Extensions.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 31.08.2023.
//

import Foundation

// MARK: - Notification key for ProfileImage

extension Notification {

  static let userInfoImageURLKey: String = "URL"

  var userInfoImageURL: String? {
    userInfo?[Notification.userInfoImageURLKey] as? String
  }
}
