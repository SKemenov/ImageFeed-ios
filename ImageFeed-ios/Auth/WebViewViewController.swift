//
//  WebViewViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 06.08.2023.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
  // MARK: - Outlets

  @IBOutlet private weak var webView: WKWebView!

  // MARK: - Private properties

  private let showWebViewSegueIdentifier = "ShowWebView"

  // MARK: - Public properties
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }


  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    setupUnsplashAuthWebView()
  }

  // MARK: - Actions

  @IBAction private func didTapBackButton() {
    // (_ sender: Any?)
    dismiss(animated: true)
  }
}

// MARK: - Ext: Private methods

private extension WebViewViewController {
  func setupUnsplashAuthWebView() {
    guard var urlComponents = URLComponents(string: unsplashAuthorizeURLString) else { return }
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
}

// MARK: - Ext: WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let code = code(from: navigationAction) {
      // TODO: process code, after that cancel the request, because we've already received the token
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
}
