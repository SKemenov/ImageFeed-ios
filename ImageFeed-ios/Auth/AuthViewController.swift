//
//  AuthViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 06.08.2023.
//

import UIKit

// MARK: - Protocol
protocol AuthViewControllerDelegate: AnyObject {
  func authViewController(_ viewController: AuthViewController)
}


final class AuthViewController: UIViewController {
  // MARK: - Private properties

  private let showWebViewSegueIdentifier = "ShowWebView"
  private let oAuth2TokenStorage = OAuth2TokenStorage()
  private let oAuth2Service = OAuth2Service()

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

// MARK: - Private Methods

private extension AuthViewController {
  func fetchAuthToken(with code: String) {
    oAuth2Service.fetchAuthToken(with: code) { [weak self] result in
      guard let self else { preconditionFailure("Cannot make weak link") }
      switch result {
        //      case .success(let result):
      case .success(let result):
        print("ITS LIT \(result)")
        self.delegate?.authViewController(self)
      case .failure(let error):
        print("The error \(error)")
      }
    }
  }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String) {
    fetchAuthToken(with: code)
  }

  func webViewViewControllerDidCancel(_ viewController: WebViewViewController) {
    dismiss(animated: true)
  }
}
