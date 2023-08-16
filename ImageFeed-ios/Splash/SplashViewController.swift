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

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    print("ITS LIT Start Splash \(oAuth2TokenStorage.token)")
    if oAuth2TokenStorage.token == nil {
      performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
    } else {
      switchToTabBarController()
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
print("ITS LIT Go to TabBar")
    let tabBarController = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "TabBarViewController")
    window.rootViewController = tabBarController
  }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
  func authViewController(_ viewController: AuthViewController) {
    print("ITS LIT Return to SplashViewController without the code")
    dismiss(animated: true) { [weak self] in
      guard let self else { preconditionFailure("Cannot make weak link") }
      self.switchToTabBarController()
    }
  }
}
