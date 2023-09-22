//
//  WebViewPresenterSpy.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 22.09.2023.
//

import Foundation
import ImageFeed_ios

final class WebViewPresenterSpy: WebViewPresenterProtocol {
  var viewDidLoadCalled = false
  var view: WebViewViewControllerProtocol?

  func viewDidLoad() {
    viewDidLoadCalled = true
  }

  func didUpdateProgressValue(_ newValue: Double) { }

  func code(from url: URL) -> String? {
    nil
  }
}
