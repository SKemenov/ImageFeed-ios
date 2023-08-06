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
  private var profileDescLabel = UILabel()
  private var exitButton = UIButton()

  // MARK: - Mock data
  private let profilePhoto = "photo_mock"
  private let profileUserName = "Константин Константинопольский"
  private let profileLoginName = "@konstantin_kon"
  private let profileDescription = "Hello, swift!"

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    makeProfilePhotoImage()
    makeProfileFullNameLabel()
    makeProfileLoginNameLabel()
    makeProfileBioLabel()
    makeProfileExitButton()
  }
}

// MARK: - Private methods

private extension ProfileViewController {
  @objc func didTapButton() {
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
    profileFullNameLabel.text = profileUserName
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
    profileLoginNameLabel.text = profileLoginName
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
    profileDescLabel.text = profileDescription
    profileDescLabel.textColor = .ypWhite
    profileDescLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)

    profileDescLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(profileDescLabel)

    NSLayoutConstraint.activate([
      profileDescLabel.topAnchor.constraint(equalTo: profileLoginNameLabel.bottomAnchor, constant: 8),
      profileDescLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      profileDescLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
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
