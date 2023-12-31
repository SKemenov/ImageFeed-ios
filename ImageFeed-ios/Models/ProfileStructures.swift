//
//  ProfileStructures.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 28.08.2023.
//

import Foundation

// MARK: - Struct

// It's public for unit tests
public struct Profile {
  let username: String
  public let name: String
  public let loginName: String
  public let bio: String?
}

struct ProfileImage: Codable {
  let small: String?
  let medium: String?
  let large: String?
}

// TODO: Use SnakeCaseJSONDecoder instead of SJONDecoder with CodingKeys enum
struct ProfileResult: Codable {
  let username: String
  let firstName: String?
  let lastName: String?
  let bio: String?
  let profileImage: ProfileImage?
}


// MARK: - Init for Profile with ProfileResult

extension Profile {

  init(result profile: ProfileResult) {
    self.init(
      username: profile.username,
      name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
      loginName: "@\(profile.username)",
      bio: profile.bio
    )
  }
}
