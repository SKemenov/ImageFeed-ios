//
//  ImageListCell.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 12.07.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
  // MARK: - Outlets

  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var likeButton: UIButton!

  // MARK: - Public properties

  static let reuseIdentifier = "ImagesListCell"
}

// MARK: - Methods

extension ImagesListCell {

  func config(image: UIImage?, date: String, isLiked: Bool) {

    let likedImage = isLiked ? UIImage(named: "like_active_on") : UIImage(named: "like_active_off")

    imageCell.image = image
    dateLabel.text = date
    likeButton.setImage(likedImage, for: .normal)
  }
}
