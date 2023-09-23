//
//  ProfileViewControllerSpy.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 23.09.2023.
//

import Foundation
import ImageFeed_ios
import UIKit.UILabel

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
  var presenter: ImageFeed_ios.ProfilePresenterProtocol?

  var viewDidUpdateAvatar = false
  var viewDidLoadProfile = false

  var profileFullNameLabel = UILabel()
  var profileLoginNameLabel = UILabel()
  var profileBioLabel = UILabel()

  func updateAvatar(url: URL) {
    viewDidUpdateAvatar = true
  }

  func loadProfile(_ profile: ImageFeed_ios.Profile?) {
    viewDidLoadProfile = true
    if let profile {
      profileFullNameLabel.text = profile.name
      profileLoginNameLabel.text = profile.loginName
      profileBioLabel.text = profile.bio
    }
  }
}
