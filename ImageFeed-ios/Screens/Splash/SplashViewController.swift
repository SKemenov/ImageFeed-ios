//
//  SplashViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 15.08.2023.
//

import UIKit

final class SplashViewController: UIViewController {
  // MARK: - Private properties

  private var unsplashLogoImage = UIImageView()
  private let oAuth2Service = OAuth2Service.shared
  private let profileService = ProfileService.shared
  private let profileImageService = ProfileImageService.shared
  private var alertPresenter: AlertPresenting?
  private var wasChecked = false

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func loadView() {
    view = UIView()
    view.backgroundColor = .ypBackground
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    alertPresenter = AlertPresenter(viewController: self)
    setupSplashViewController()
    UIBlockingProgressHUD.setup()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    checkAuthStatus()
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
    }
  }

  func showLoginAlert(error: Error) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let alertModel = AlertModel(
        title: "Что-то пошло не так :(",
        message: "Не удалось войти в систему: \(error.localizedDescription)",
        buttonText: "Ok") {
          self.wasChecked = false
          guard OAuth2TokenStorage.shared.removeToken() else {
            assertionFailure("Cannot remove token")
            return
          }
          self.checkAuthStatus()
      }
      self.alertPresenter?.showAlert(for: alertModel)
    }
  }
}

// MARK: - Private methods to make UI

private extension SplashViewController {

  func showAuthViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: .main)
    let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
    guard let viewController = viewController as? AuthViewController else { return }
    viewController.delegate = self
    viewController.modalPresentationStyle = .fullScreen
    present(viewController, animated: true)
  }

  func switchToTabBarController() {
    guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
    let tabBarController = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "TabBarViewController")
    window.rootViewController = tabBarController
  }

  func setupSplashViewController() {
    unsplashLogoImage.image = UIImage(named: "logo")
    unsplashLogoImage.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(unsplashLogoImage)

    NSLayoutConstraint.activate([
      unsplashLogoImage.widthAnchor.constraint(equalToConstant: 75),
      unsplashLogoImage.heightAnchor.constraint(equalToConstant: 77),
      unsplashLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
      unsplashLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
    ])
  }
}

// MARK: - Private fetch methods

private extension SplashViewController {

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
        print("ITS LIT 136 \(error)")
        UIBlockingProgressHUD.dismiss()
      }
    }
  }

  func fetchProfile(completion: @escaping () -> Void) {

    profileService.fetchProfile { [weak self] profileResult in
      guard let self else { preconditionFailure("Cannot fetch profileResult") }

      switch profileResult {
      case .success(let profile):
        let userName = profile.username
        self.fetchProfileImage(userName: userName)
        self.switchToTabBarController()
      case .failure(let error):
        print("ITS LIT 152 \(error)")
        self.showLoginAlert(error: error)
      }
      completion()
    }
  }

  func fetchProfileImage(userName: String) {

    profileImageService.fetchProfileImageURL(userName: userName) { [weak self] profileImageUrl in

      guard let self else { return }

      switch profileImageUrl {
      case .success(let mediumPhoto):
        print("ITS LIT \(mediumPhoto)")
      case .failure(let error):
        self.showLoginAlert(error: error)
        print("ITS LIT 171\(error)")
      }
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