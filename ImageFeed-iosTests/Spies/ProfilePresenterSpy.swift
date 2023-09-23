//
//  ProfilePresenterSpy.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 23.09.2023.
//

import Foundation
import ImageFeed_ios

final class ProfilePresenterSpy: ProfilePresenterProtocol {
  var view: ProfileViewControllerProtocol?

  var viewDidLoadCalled = false
  var viewDidResetAccount = false

  func viewDidLoad() {
    viewDidLoadCalled = true
  }

  func resetAccount() {
    viewDidResetAccount = true
  }
}
