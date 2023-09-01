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
  // MARK: - Private properties

  private var estimatedProgressObservation: NSKeyValueObservation?

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
    setupWebViewObserve()
    setupUnsplashAuthWebView()
  }

  // MARK: - Actions

  @IBAction private func didTapBackButton(_ sender: Any?) {
    delegate?.webViewViewControllerDidCancel(self)
  }
}

// MARK: - Private methods

private extension WebViewViewController {

  func setupWebViewObserve() {
    estimatedProgressObservation = webView.observe(\.estimatedProgress, options: []) {
      [weak self ] _, _ in
      guard let self else { return }
      self.updateProgress()
    }
  }

  func setupUnsplashAuthWebView() {

    guard var urlComponents = URLComponents(string: Constants.authorizeURLString) else {
      preconditionFailure("Incorrect \(Constants.authorizeURLString) string")
    }
    urlComponents.queryItems = [
      URLQueryItem(name: WebElements.clientId, value: Constants.accessKey),
      URLQueryItem(name: WebElements.redirectUri, value: Constants.redirectURI),
      URLQueryItem(name: WebElements.responseType, value: Constants.code),
      URLQueryItem(name: WebElements.scope, value: Constants.accessScope)
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
      urlComponents.path == Constants.authorizedURLPath,
      let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == Constants.code }) {
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