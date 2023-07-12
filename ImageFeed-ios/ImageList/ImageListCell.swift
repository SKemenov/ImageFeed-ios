//
//  ImageListCell.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 12.07.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
  static let reuseIdentifier = "ImagesListCell"

  @IBOutlet var imageCell: UIImageView!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var likeButton: UIButton!
}

extension ImagesListCell {
  func config(image: UIImage?, date: String, isLiked: Bool) {
    let likedImage = isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")

    imageCell.image = image
    dateLabel.text = date
    likeButton.setImage(likedImage, for: .normal)
  }
}
