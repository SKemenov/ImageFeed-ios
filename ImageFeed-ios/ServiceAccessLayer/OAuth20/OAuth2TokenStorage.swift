//
//  OAuth2TokenStorage.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 09.08.2023.
//

import Foundation
import SwiftKeychainWrapper

// MARK: - Protocol

protocol TokenStorage {
  var token: String? { get }
}

// MARK: - Class

final class OAuth2TokenStorage {
  static let shared = OAuth2TokenStorage()

  private let keychainWrapper = KeychainWrapper.standard
}

// MARK: - TokenStorage

extension OAuth2TokenStorage: TokenStorage {
  var token: String? {
    get {
      keychainWrapper.string(forKey: Constants.bearerToken)
    }
    set {
      guard let newValue else { return }
      keychainWrapper.set(newValue, forKey: Constants.bearerToken)
    }
  }
}

extension OAuth2TokenStorage {
  func removeToken() -> Bool {
    keychainWrapper.removeObject(forKey: Constants.bearerToken)
  }
}
