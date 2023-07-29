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
  @IBOutlet private weak var shareButton: UIButton!
  @IBOutlet private weak var scrollView: UIScrollView!

  // MARK: - Public properties

  // swiftlint:disable:next implicitly_unwrapped_optional
  var image: UIImage! {
    didSet {
      guard isViewLoaded else { return }
      imageView.image = image
      //      rescaleAndCenterImageInScrollView(image: image)
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = image
//    setupScrollView()
    //    rescaleAndCenterImageInScrollView(image: image)
  }

  // MARK: - Actions

  @IBAction private func clickedBackButton() {
    dismiss(animated: true)
  }
  @IBAction private func clickedShareButton() {
    dismiss(animated: true)
  }
}

// MARK: - Private methods

// FIXME: rewrite it all
private extension SingleImageViewController {
  func setupScrollView() {
    scrollView.minimumZoomScale = 0.1
    scrollView.maximumZoomScale = 1.25
  }

  func rescaleAndCenterImageInScrollView(image: UIImage) {
    let minZoomScale = scrollView.minimumZoomScale
    let maxZoomScale = scrollView.maximumZoomScale

    view.layoutIfNeeded()
    let visibleContentSize = scrollView.bounds.size
    let imageSize = image.size
    let vScale = visibleContentSize.height / imageSize.height
    let hScale = visibleContentSize.width / imageSize.width
    let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
    scrollView.setZoomScale(scale, animated: false)

    scrollView.layoutIfNeeded()
    let newContentSize = scrollView.contentSize
    let x = (newContentSize.width - visibleContentSize.width) / 2
    let y = (newContentSize.height - visibleContentSize.height) / 2
    scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
  }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    imageView
  }
}
