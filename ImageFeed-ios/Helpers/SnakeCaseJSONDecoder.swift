//
//  SnakeCaseJSONDecoder.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 12.08.2023.
//

import Foundation

class SnakeCaseJSONDecoder: JSONDecoder {
  override init() {
    super.init()
    keyDecodingStrategy = .convertFromSnakeCase
  }
}
