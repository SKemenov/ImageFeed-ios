//
//  WebViewVewControllerSpy.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 22.09.2023.
//

import Foundation
import ImageFeed_ios

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
  var presenter: ImageFeed_ios.WebViewPresenterProtocol?
  var viewDidLoadRequest = false

  func load(request: URLRequest) {
    viewDidLoadRequest = true
  }

  func setProgressValue(_ newValue: Float) { }

  func setProgressHidden(_ flag: Bool) { }
}
