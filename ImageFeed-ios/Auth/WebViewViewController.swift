//
//  WebViewViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 06.08.2023.
//

import UIKit
import WebKit

// MARK: - Protocol
protocol WebViewViewControllerDelegate: AnyObject {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String)
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController)
}

// MARK: - Class

final class WebViewViewController: UIViewController {
  // MARK: - Private enums
  private enum WebConstants {
    static let authorizeURLString = "https://unsplash.com/oauth/authorize"
    static let authorizedURLPath = "/oauth/authorize/native"
    static let code = "code"
  }

  private enum WebElements {
    static let clientId = "client_id"
    static let redirectUri = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
  }

  // MARK: - Outlets

  @IBOutlet private weak var webView: WKWebView!
  @IBOutlet private weak var progressView: UIProgressView!

  // MARK: - Public properties

  weak var delegate: WebViewViewControllerDelegate?

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }


  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    webView.navigationDelegate = self
    setupProgress()
    setupUnsplashAuthWebView()
  }

  // MARK: - Actions

  @IBAction private func didTapBackButton(_ sender: Any?) {
    delegate?.webViewViewControllerDidCancel(self)
  }
}

// MARK: - Progress observer methods

extension WebViewViewController {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)

    webView.addObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress),
      options: .new,
      context: nil
    )
    updateProgress()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)

    webView.removeObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress)
    )
  }

  // swiftlint:disable:next block_based_kvo
  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if keyPath == #keyPath(WKWebView.estimatedProgress) {
      updateProgress()
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
}


// MARK: - Private methods

private extension WebViewViewController {
  func setupUnsplashAuthWebView() {
    guard var urlComponents = URLComponents(string: WebConstants.authorizeURLString) else {
      preconditionFailure("Incorrect \(WebConstants.authorizeURLString) string")
    }
    urlComponents.queryItems = [
      URLQueryItem(name: WebElements.clientId, value: accessKey),
      URLQueryItem(name: WebElements.redirectUri, value: redirectURI),
      URLQueryItem(name: WebElements.responseType, value: WebConstants.code),
      URLQueryItem(name: WebElements.scope, value: accessScope)
    ]
    guard let url = urlComponents.url else {
      print(CancellationError())
      return
    }
    let request = URLRequest(url: url)
    webView.load(request)
  }

  func code(from navigationAction: WKNavigationAction) -> String? {
    if
      let url = navigationAction.request.url,
      let urlComponents = URLComponents(string: url.absoluteString),
      urlComponents.path == WebConstants.authorizedURLPath,
      let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == WebConstants.code }) {
      return codeItem.value
    } else {
      return nil
    }
  }

  func setupProgress() {
    progressView.progressTintColor = .ypBlack
    progressView.trackTintColor = .ypGray
    progressView.progressViewStyle = .bar
  }

  func updateProgress() {
    progressView.progress = Float(webView.estimatedProgress)
    progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
  }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let code = code(from: navigationAction) {
      delegate?.webViewViewController(self, didAuthenticateWithCode: code)
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
}
