//
//  SingleImageViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 19.07.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
  // MARK: - Outlets

  @IBOutlet private var imageView: UIImageView!

  // MARK: - Public properties

  // swiftlint:disable:next implicitly_unwrapped_optional
  var image: UIImage! {
    didSet {
      guard isViewLoaded else { return }
      imageView.image = image
    }
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = image
  }
}
