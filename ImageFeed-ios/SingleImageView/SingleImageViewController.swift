//
//  SingleImageViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 19.07.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
  // MARK: - Outlets

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var backButton: UIButton!

  // MARK: - Public properties

  // swiftlint:disable:next implicitly_unwrapped_optional
  var image: UIImage! {
    didSet {
      guard isViewLoaded else { return }
      imageView.image = image
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = image
  }

  @IBAction private func clickedBackButton() {
    dismiss(animated: true)
  }
}
