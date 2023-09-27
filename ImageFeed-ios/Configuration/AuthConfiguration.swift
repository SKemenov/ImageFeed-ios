//
//  AuthConfiguration.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 20.09.2023.
//

import Foundation

struct AuthConfiguration {
  let accessKey: String
  let secretKey: String
  let redirectURI: String
  let accessSCope: String
  let apiURLString: String
  let authURLString: String
  let baseURLString: String

  static var standard: AuthConfiguration {
    AuthConfiguration(
      accessKey: Constants.accessKey,
      secretKey: Constants.secureKey,
      redirectURI: Constants.redirectURI,
      accessSCope: Constants.accessScope,
      apiURLString: Constants.defaultApiBaseURLString,
      authURLString: Constants.authorizeURLString,
      baseURLString: Constants.baseURLString)
  }
}
