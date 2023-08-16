//
//  OAuth2TokenStorage.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 09.08.2023.
//

import Foundation

// MARK: - Protocol

protocol TokenStorage {
  var token: String? { get }
}

// MARK: - Class

final class OAuth2TokenStorage {
  private enum Keys: String {
    case token
  }
  private let userDefaults: UserDefaults

  // can use default values in the init() because in this case they are all time the same
  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
}

// MARK: - TokenStorage

extension OAuth2TokenStorage: TokenStorage {
  var token: String? {
    get {
      print("ITS LIT Read OAuth2TokenStorage.token")
      return userDefaults.string(forKey: Keys.token.rawValue)
    }
    set {
      print("ITS LIT Write OAuth2TokenStorage.token")
      return userDefaults.set(newValue, forKey: Keys.token.rawValue)
    }
  }
}
