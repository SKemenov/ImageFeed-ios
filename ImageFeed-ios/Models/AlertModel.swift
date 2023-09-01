//
//  AlertModel.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 01.09.2023.
//

import Foundation

struct AlertModel {
  let title: String
  let message: String
  let buttonText: String
  let completion: (() -> Void)?
}
