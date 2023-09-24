//
//  ProfileViewPresenter.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 22.09.2023.
//

import Foundation
import WebKit
import Kingfisher

// MARK: - Protocol

public protocol ProfilePresenterProtocol {
  var view: ProfileViewControllerProtocol? { get set }
  func viewDidLoad()
  func resetAccount()
}

// MARK: - Class

final class ProfilePresenter {
  // MARK: - Private properties

  private let profileImageService = ProfileImageService.shared
  private let profileService = ProfileService.shared

  // MARK: - Public properties

  weak var view: ProfileViewControllerProtocol?
}

// MARK: - ProfilePresenterProtocol

extension ProfilePresenter: ProfilePresenterProtocol {

  func viewDidLoad() {
    checkAvatar()
    checkProfile()
  }

  func resetAccount() {
    resetToken()
    resetView()
    resetImageCache()
    resetPhotos()
    resetCookies()
    switchToSplashViewController()
  }
}

// MARK: - Private methods

private extension ProfilePresenter {

  func checkAvatar() {
    if let url = profileImageService.avatarURL {
      view?.updateAvatar(url: url)
    }
  }

  func checkProfile() {
    guard let profile = profileService.profile else {
      return
    }
    view?.loadProfile(profile)
  }

  func resetToken() {
    guard OAuth2TokenStorage.shared.removeToken() else {
      assertionFailure("Cannot remove token")
      return
    }
  }

  func resetView() {
    view?.loadProfile(nil)
  }

  func resetImageCache() {
    let cache = ImageCache.default
    cache.clearMemoryCache()
    cache.clearDiskCache()
  }

  func resetPhotos() {
    ImageListService.shared.resetPhotos()
  }

  func resetCookies() {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
      records.forEach { record in
        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) { }
      }
    }
  }

  func switchToSplashViewController() {
    guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
    let splashViewController = SplashViewController()
    window.rootViewController = splashViewController
  }
}
