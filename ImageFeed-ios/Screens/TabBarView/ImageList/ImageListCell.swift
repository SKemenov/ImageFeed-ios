//
//  ImageListCell.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 12.07.2023.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
  // MARK: - Outlets

  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var likeButton: UIButton!

  private let placeholderImage = UIImage(named: "stub")

  // MARK: - Public properties

  static let reuseIdentifier = "ImagesListCell"

  override func prepareForReuse() {
    super.prepareForReuse()
    imageCell.kf.cancelDownloadTask()
  }
}

// MARK: - Methods

extension ImagesListCell {

  func loadCell(from photo: Photo) -> Bool {
    var status = false

    if let photoDate = photo.createdAt {
      dateLabel.text = Constants.dateFormatter.string(from: photoDate)
    }

    let likedImage = photo.isLiked ? UIImage(named: "like_active_on") : UIImage(named: "like_active_off")
    likeButton.setImage(likedImage, for: .normal)

    guard let photoURL = URL(string: photo.thumbImageURL) else { return status }

    imageCell.kf.indicatorType = .activity
    imageCell.kf.setImage(with: photoURL, placeholder: placeholderImage) { [weak self] result in
      guard let self else { return }
      switch result {
        // swiftlint:disable:next empty_enum_arguments
      case .success(_):
        status = true
      case .failure(let error):
        imageCell.image = placeholderImage
        print("ITS LIT ILC 68 \(error.localizedDescription)")
      }
    }
    return status
  }
}
