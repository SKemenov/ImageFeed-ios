//
//  PhotoStructures.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 04.09.2023.
//

import Foundation

// MARK: - Struct

struct Photo {
  let id: String
  let size: CGSize
  let createdAt: Date
  let welcomeDescription: String?
  let thumbImageURL: String
  let largeImageURL: String
  let isLiked: Bool
}

struct UrlsResult: Codable {
  let thumb: String
  let full: String
}

// TODO: Use SnakeCaseJSONDecoder instead of SJONDecoder with CodingKeys enum
struct PhotoResult: Codable {
  let id: String
  let width: Int
  let height: Int
  let createdAt: String
  let description: String?
  let likedByUser: Bool
  let urls: UrlsResult
}
