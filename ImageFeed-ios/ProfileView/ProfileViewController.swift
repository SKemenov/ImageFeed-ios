//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 18.07.2023.
//

import UIKit

final  class ProfileViewController: UIViewController {

  // MARK: - Private properties
  private var profilePhotoImage = UIImageView()
  private var profileFullNameLabel = UILabel()
  private var profileLoginNameLabel = UILabel()
  private var profileBioLabel = UILabel()
  private var exitButton = UIButton()

  private let profileService = ProfileService.shared
  private let profileImageService = ProfileImageService.shared

  private var profileImageServiceObserver: NSObjectProtocol?

  // FIXME: Disable after check SplashViewController flow
  private let storage = OAuth2TokenStorage.shared


  // MARK: - Mock data
  private let profilePhoto = "photo_mock"
  //  private let profileUserName = "Константин Константинопольский"
  //  private let profileLoginName = "@konstantin_kon"
  //  private let profileBio = "Hello, swift!"

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    if profileService.profile != nil {
      print("ITS LIT \(String(describing: profileService.profile))")
    } else {
      print("ITS LIT profileService.profile is nil")
    }

    if profileImageService.avatarURL != nil {
      print("ITS LIT \(String(describing: profileImageService.avatarURL))")
    } else {
      print("ITS LIT profileImageService.avatarURL is nil")
    }

    if let url = profileImageService.avatarURL {
      updateAvatar(url: url)
    }

    profileImageServiceObserver = NotificationCenter.default.addObserver(
      forName: ProfileImageService.didChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      self?.updateAvatar(notification: notification)
    }

    makeProfilePhotoImage()
    makeProfileFullNameLabel()
    makeProfileLoginNameLabel()
    makeProfileBioLabel()
    makeProfileExitButton()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadProfile()
  }
}

// MARK: - Private methods

private extension ProfileViewController {

  @objc func didTapButton() {

    // just to check the SplashViewController flow
    resetToken()
    switchToSplashViewController()
  }

  @objc func updateAvatar(notification: Notification) {

    guard
      isViewLoaded,
      let userInfo = notification.userInfo,
      let profileImageURL = userInfo["URL"] as? String,
      let url = URL(string: profileImageURL)
    else { return }

    updateAvatar(url: url)
  }

  func updateAvatar(url: URL) {
    //    profileImage.kf.indicatiorType = .activity
    //    let processor = RoundCornerImageProcessor(cornerRadius: 61)
    //    profileImage.kf.setImage(with: url, options: [.processor(processor)])
  }

  func loadProfile() {

    guard let profile = profileService.profile else {
      assertionFailure("Has no profile")
      return
    }

    self.profileFullNameLabel.text = profile.name
    self.profileLoginNameLabel.text = profile.loginName
    self.profileBioLabel.text = profile.bio
  }

  func makeProfilePhotoImage() {

    profilePhotoImage.image = UIImage(named: profilePhoto)
    profilePhotoImage.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(profilePhotoImage)

    NSLayoutConstraint.activate([
      profilePhotoImage.widthAnchor.constraint(equalToConstant: 70),
      profilePhotoImage.heightAnchor.constraint(equalToConstant: 70),
      profilePhotoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
      profilePhotoImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
    ])
  }

  func makeProfileFullNameLabel() {

    //    profileFullNameLabel.text = profileUserName
    profileFullNameLabel.textColor = .ypWhite
    profileFullNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
    profileFullNameLabel.lineBreakMode = .byWordWrapping
    profileFullNameLabel.numberOfLines = 2

    profileFullNameLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(profileFullNameLabel)

    NSLayoutConstraint.activate([
      profileFullNameLabel.topAnchor.constraint(equalTo: profilePhotoImage.bottomAnchor, constant: 8),
      profileFullNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      profileFullNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
    ])
  }

  func makeProfileLoginNameLabel() {

    //    profileLoginNameLabel.text = profileLoginName
    profileLoginNameLabel.textColor = .ypGray
    profileLoginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)

    profileLoginNameLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(profileLoginNameLabel)

    NSLayoutConstraint.activate([
      profileLoginNameLabel.topAnchor.constraint(equalTo: profileFullNameLabel.bottomAnchor, constant: 8),
      profileLoginNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      profileLoginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
    ])
  }

  func makeProfileBioLabel() {

    //    profileBioLabel.text = profileBio
    profileBioLabel.textColor = .ypWhite
    profileBioLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    profileBioLabel.lineBreakMode = .byWordWrapping
    profileBioLabel.numberOfLines = 0

    profileBioLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(profileBioLabel)

    NSLayoutConstraint.activate([
      profileBioLabel.topAnchor.constraint(equalTo: profileLoginNameLabel.bottomAnchor, constant: 8),
      profileBioLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      profileBioLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
    ])
  }

  func makeProfileExitButton() {

    let profileExitButtonImage = UIImage(named: "ipad.and.arrow.forward") ?? UIImage()

    exitButton = UIButton.systemButton(
      with: profileExitButtonImage,
      target: self,
      action: #selector(self.didTapButton)
    )
    exitButton.tintColor = .ypRed

    exitButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(exitButton)

    NSLayoutConstraint.activate([
      exitButton.widthAnchor.constraint(equalToConstant: 44),
      exitButton.heightAnchor.constraint(equalToConstant: 44),
      exitButton.centerYAnchor.constraint(equalTo: profilePhotoImage.centerYAnchor),
      exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
    ])
  }
}

// MARK: - Private methods to check SplashViewController flow

private extension ProfileViewController {

  func resetToken() {

    guard storage.removeToken() else {
      assertionFailure("Cannot remove token")
      return
    }
  }

  func switchToSplashViewController() {

    guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
    let splashViewController = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "SplashViewControllerID")
    window.rootViewController = splashViewController
  }
}
