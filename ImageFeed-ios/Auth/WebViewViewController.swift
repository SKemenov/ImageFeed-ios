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

  // MARK: - Actions

  @IBAction private func didTapBackButton() {
    dismiss(animated: true)
  }
}
