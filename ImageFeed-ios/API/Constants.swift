//
//  Constants.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 03.08.2023.
//

import Foundation

// MARK: - Public properties

// Unsplash API rules
// 1. The API is to be used for non-automated, high-quality, and authentic experiences.
// 2. You cannot replicate the core user experience of Unsplash (unofficial clients, wallpaper applications, etc.).
// 3. Your Access Key and Secret Key must remain confidential.
// 4. Do not abuse the API. Too many requests too quickly will get your access turned off.

enum Constants {

  // MARK: - Unsplash API constants for app
  static let accessKey = "IgH-MbheyUstaJWCnPaQc2gtrMXJyISlRHyzSdpZI5E"
  static let secureKey = "H64ks3MlhldqtzwBGDXiLN6OdvL8ML0isXVDwI0hzb4"
  static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
  static let accessScope = "public+read_user+write_likes"

  // MARK: - Unsplash base URLs
  static let defaultApiBaseURLString = "https://api.unsplash.com"
  static let baseURLString = "https://unsplash.com"
  static let authorizeURLString = "https://unsplash.com/oauth/authorize"

  // MARK: - Unsplash base AIP paths
  static let authorizedURLPath = "/oauth/authorize/native"
  static let tokenRequestPathString = "/oauth/token"
  static let profileRequestPathString = "/me"

  // MARK: - Request method's strings
  static let postMethodString = "POST"
  static let getMethodString = "GET"

  // MARK: - Storage constants
  static let tokenRequestGrantTypeString = "authorization_code"
  static let code = "code"
  static let bearerToken = "bearerToken"

  static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM YYYY"
    return dateFormatter
  }()
}
