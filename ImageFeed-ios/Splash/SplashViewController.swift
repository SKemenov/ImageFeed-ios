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
  private let oAuth2Service = OAuth2Service.shared
  private let profileService = ProfileService()
  private let alertPresenter = AlertPresenter()
  private var wasChecked = false

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    alertPresenter.delegate = self
    UIBlockingProgressHUD.setup()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    checkAuthStatus()
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

  func checkAuthStatus() {

    guard !wasChecked else { return }
    wasChecked = true
    if oAuth2Service.isAuthenticated {
      UIBlockingProgressHUD.show()

      fetchProfile { [weak self] in
        UIBlockingProgressHUD.dismiss()
        self?.switchToTabBarController()
      }
    } else {
      showAuthViewController()
      //      performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
    }
  }

  func showAuthViewController() {

    let storyboard = UIStoryboard(name: "Main", bundle: .main)
    let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewControllerID")
    guard let viewController = viewController as? AuthViewController else { return }
    viewController.delegate = self
    viewController.modalPresentationStyle = .fullScreen
    present(viewController, animated: true)
  }

  func switchToTabBarController() {

    guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
    let tabBarController = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "TabBarViewControllerID")
    window.rootViewController = tabBarController
  }

  func setupSplashViewController() {

    let storyboard = UIStoryboard(name: "Main", bundle: .main)
    storyboard.instantiateInitialViewController() // use it for "is Initial VC"
  }

  func showLoginAlert(error: Error) {

    alertPresenter.showAlert(
      title: "Что-то пошло не так (",
      message: "Не удалось войти в систему \(error.localizedDescription)") {
        self.performSegue(withIdentifier: self.showAuthViewSegueIdentifier, sender: nil)
    }
  }

  func fetchAuthToken(with code: String) {

    UIBlockingProgressHUD.show()

    oAuth2Service.fetchAuthToken(with: code) { [weak self] authResult in

      guard let self else { preconditionFailure("Cannot fetch auth token") }

      switch authResult {
        // swiftlint:disable:next empty_enum_arguments
      case .success(_):
        print("ITS LIT has token")
        self.fetchProfile(completion: {
          UIBlockingProgressHUD.dismiss()
        })
      case .failure(let error):
        self.showLoginAlert(error: error)
        UIBlockingProgressHUD.dismiss()
      }
    }
  }

  func fetchProfile(completion: @escaping () -> Void) {

    profileService.fetchProfile { [weak self] profileResult in

      guard let self else { preconditionFailure("Cannot fetch profileResult") }

      switch profileResult {
        // swiftlint:disable:next empty_enum_arguments
      case .success(_):
        self.switchToTabBarController()
      case .failure(let error):
        self.showLoginAlert(error: error)
      }
      completion()
    }
  }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {

  func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String) {

    dismiss(animated: true) {
      [weak self] in
      guard let self else { return }
      self.fetchAuthToken(with: code)
    }
  }
}
