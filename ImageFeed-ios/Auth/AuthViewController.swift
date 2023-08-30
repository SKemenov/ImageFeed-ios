//
//  AuthViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 06.08.2023.
//

import UIKit

// MARK: - Protocol
protocol AuthViewControllerDelegate: AnyObject {
  func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String)
}


final class AuthViewController: UIViewController {
  // MARK: - Private properties

  private let showWebViewSegueIdentifier = "ShowWebView"

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  weak var delegate: AuthViewControllerDelegate?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - public methods

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == showWebViewSegueIdentifier {
      guard let webViewViewController = segue.destination as? WebViewViewController else {
        preconditionFailure("Error with \(showWebViewSegueIdentifier)")
      }
      webViewViewController.delegate = self
    } else {
      super.prepare(for: segue, sender: sender)
    }
  }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {

  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String) {
    delegate?.authViewController(self, didAuthenticateWithCode: code)
  }

  func webViewViewControllerDidCancel(_ viewController: WebViewViewController) {
    dismiss(animated: true)
  }
}
