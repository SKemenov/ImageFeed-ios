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

final class WebViewPresenter: WebViewPresenterProtocol {
  weak var view: WebViewViewControllerProtocol?

  func viewDidLoad() {
    setupUnsplashAuthWebView()
  }

  func didUpdateProgressValue(_ newValue: Double) {
    let newProgressValue = Float(newValue)
    view?.setProgressValue(newProgressValue)

    let shouldProgressHidden = shouldHideProgress(for: newProgressValue)
    view?.setProgressHidden(shouldProgressHidden)
  }

  func code(from url: URL) -> String? {
    if
      let urlComponents = URLComponents(string: url.absoluteString),
      urlComponents.path == Constants.authorizedURLPath,
      let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == Constants.code }) {
      return codeItem.value
    } else {
      return nil
    }
  }
}

private extension WebViewPresenter {
  enum WebElements {
    static let clientId = "client_id"
    static let redirectUri = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
  }

  func shouldHideProgress(for value: Float) -> Bool {
    abs(value - 1.0) <= 0.0001
  }

  func setupUnsplashAuthWebView() {
    guard var urlComponents = URLComponents(string: AuthConfiguration.standard.authURLString) else {
      preconditionFailure("Incorrect \(AuthConfiguration.standard.authURLString) string")
    }
    urlComponents.queryItems = [
      URLQueryItem(name: WebElements.clientId, value: AuthConfiguration.standard.accessKey),
      URLQueryItem(name: WebElements.redirectUri, value: AuthConfiguration.standard.redirectURI),
      URLQueryItem(name: WebElements.responseType, value: Constants.code),
      URLQueryItem(name: WebElements.scope, value: AuthConfiguration.standard.accessSCope)
    ]
    guard let url = urlComponents.url else {
      print(CancellationError())
      return
    }
    let request = URLRequest(url: url)

    didUpdateProgressValue(0)

    view?.load(request: request)
  }
}
