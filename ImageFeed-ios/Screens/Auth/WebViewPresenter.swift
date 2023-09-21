//
//  WebViewPresenter.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 19.09.2023.
//

import Foundation

// MARK: - Protocol // Why in the textbook this protocol is public?

protocol WebViewPresenterProtocol {
  var view: WebViewViewControllerProtocol? { get set }
  func viewDidLoad()
  func didUpdateProgressValue(_ newValue: Double)
  func code(from url: URL) -> String?
}

// MARK: - Class

final class WebViewPresenter {
  // MARK: - Private properties

  private var webViewWasLoaded = false // to prevent revers progressView animation

  // MARK: - Public properties

  weak var view: WebViewViewControllerProtocol?
  var authHelper: AuthHelperProtocol

  // MARK: - Init

  init(authHelper: AuthHelperProtocol) {
    self.authHelper = authHelper
  }
}

// MARK: - Private properties & methods

private extension WebViewPresenter {
  func shouldHideProgress(for value: Float) -> Bool {
    abs(value - 1.0) <= 0.001
  }
}

// MARK: - WebViewPresenterProtocol

extension WebViewPresenter: WebViewPresenterProtocol {
  func viewDidLoad() {
    let request = authHelper.authRequest()
    view?.load(request: request)
    didUpdateProgressValue(0)
  }

  func didUpdateProgressValue(_ newValue: Double) {
    if !webViewWasLoaded {
      let newProgressValue = Float(newValue)
      view?.setProgressValue(newProgressValue)

      let shouldProgressHidden = shouldHideProgress(for: newProgressValue)
      view?.setProgressHidden(shouldProgressHidden)
      if shouldProgressHidden {
        webViewWasLoaded = true
      }
    }
  }

  func code(from url: URL) -> String? {
    authHelper.code(from: url)
  }
}
