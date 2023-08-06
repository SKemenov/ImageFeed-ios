//
//  Constants.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 03.08.2023.
//

import Foundation

// MARK: - Public properties

// The API is to be used for non-automated, high-quality, and authentic experiences.
// You cannot replicate the core user experience of Unsplash (unofficial clients, wallpaper applications, etc.).
// Your Access Key and Secret Key must remain confidential.
// Do not abuse the API. Too many requests too quickly will get your access turned off.

public let accessKey = "IgH-MbheyUstaJWCnPaQc2gtrMXJyISlRHyzSdpZI5E"
public let secureKey = "H64ks3MlhldqtzwBGDXiLN6OdvL8ML0isXVDwI0hzb4"
public let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
public let accessScope = "public+read_user+write_likes"

// defaultBaseURL is optional
public let defaultBaseURL = URL(string: "https://api.unsplash.com")
public let defaultAPIURL = URL(string: "https://api.unsplash.com")
