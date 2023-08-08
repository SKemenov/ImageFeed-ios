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
  private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

  // MARK: - Outlets

  @IBOutlet private weak var webView: WKWebView!
  @IBOutlet private weak var progressView: UIProgressView!

  // MARK: - Public properties

  weak var delegate: WebViewViewControllerDelegate?

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }


  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)

    webView.addObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress),
      options: .new,
      context: nil
    )
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)

    webView.removeObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress)
    )
  }

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

  // MARK: - Public methods

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
    guard var urlComponents = URLComponents(string: unsplashAuthorizeURLString) else {
      print("Incorrect unsplashAuthorizeURLString string")
      return
    }
    urlComponents.queryItems = [
      URLQueryItem(name: "client_id", value: accessKey),
      URLQueryItem(name: "redirect_uri", value: redirectURI),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: accessScope)
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
      urlComponents.path == "/oauth/authorize/native",
      let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == "code" }) {
      print("urlComponents \(urlComponents)")
      print("urlComponents.path \(urlComponents.path)")
      print("items \(items)")
      print("codeItem.name, .value \(codeItem.name) \(codeItem.value ?? "can't take value")")
      return codeItem.value
    } else {
      print("can't take url")
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
      // TODO: process code, after that cancel the request, because we've already received the token
      print(code)
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
}
