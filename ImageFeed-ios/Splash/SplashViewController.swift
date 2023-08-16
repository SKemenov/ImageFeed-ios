//
//  SplashViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 15.08.2023.
//

import UIKit

final class SplashViewController: UIViewController {
  // MARK: - Private properties

  private let showAuthViewSegueIdentifier = "ShowAuthView"
  private let oAuth2TokenStorage = OAuth2TokenStorage()

  // MARK: - Lifecycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    if let token = oAuth2TokenStorage.token {
      switchToTabBarController()
    } else {
      performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == showAuthViewSegueIdentifier {
      guard
        let navigationController = segue.destination as? UINavigationController,
        let viewController = navigationController.viewControllers[0] as? AuthViewController else {
        preconditionFailure("Error with \(showAuthViewSegueIdentifier)")
      }
      viewController.delegate = self
    } else {
      super.prepare(for: segue, sender: sender)
    }
  }
}

// MARK: - Private methods

private extension SplashViewController {
  func switchToTabBarController() {
    guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
    let tabBarController = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "TabBarViewController")
    window.rootViewController = tabBarController
  }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
  func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String) {
    dismiss(animated: true) { [weak self] in
      guard let self else { return }
      self.switchToTabBarController()
    }
  }
}
