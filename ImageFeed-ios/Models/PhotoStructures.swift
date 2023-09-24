//
//  PhotoStructures.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 04.09.2023.
//

import Foundation

// MARK: - Struct

public struct Photo {
  let id: String
  let size: CGSize
  let createdAt: Date?
  let welcomeDescription: String?
  let thumbImageURL: String
  let largeImageURL: String
  var isLiked: Bool
  let thumbSize: CGSize
}

struct UrlsResult: Codable {
  let small: String
  let full: String
}

struct LikeResult: Codable {
  let photo: PhotoLikeResult
}

struct PhotoLikeResult: Codable {
  let likedByUser: Bool
}

// TODO: Use SnakeCaseJSONDecoder instead of SJONDecoder with CodingKeys enum
struct PhotoResult: Codable {
  let id: String
  let width: Int
  let height: Int
  let createdAt: String?
  let description: String?
  var likedByUser: Bool
  let urls: UrlsResult
}
