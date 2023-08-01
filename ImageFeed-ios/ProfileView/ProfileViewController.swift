//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 18.07.2023.
//

import UIKit

final  class ProfileViewController: UIViewController {
  // MARK: - Outlets

  @IBOutlet private weak var profilePhotoImage: UIImageView!
  @IBOutlet private weak var profileFullNameLabel: UILabel!
  @IBOutlet private weak var profileLoginNameLabel: UILabel!
  @IBOutlet private weak var profileBioLabel: UILabel!
  @IBOutlet private weak var exitButton: UIButton!

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecyrcle

  override func viewDidLoad() {
    super.viewDidLoad()

    makeProfilePhotoImage()
    makeProfileFullNameLabel()
    makeProfileLoginNameLabel()
    makeProfileBioLabel()
    makeProfileExitButton()
  }

  // MARK: - Actions

  @IBAction func didTapExitButton() {
  }
}

// MARK: - Private methods

private extension ProfileViewController {
  func makeProfilePhotoImage() {
    profilePhotoImage?.image = UIImage(named: "photo")
  }

  func makeProfileFullNameLabel() {
    profileFullNameLabel.text = "Константин Константинопольский"
  }

  func makeProfileLoginNameLabel() {
    profileLoginNameLabel.text = "@konstantin_kon"
  }

  func makeProfileBioLabel() {
    profileBioLabel.text = "Hello, swift!"
  }

  func makeProfileExitButton() { }
}
