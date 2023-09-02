//
//  URLRequest+Extensions.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 11.08.2023.
//

import Foundation

// MARK: - Custom URLRequest implementation

final class URLRequestBuilder {
  // MARK: - Private properties

  static let shared = URLRequestBuilder()
  private let storage = OAuth2TokenStorage.shared

  // MARK: - Methods

  func makeHTTPRequest(path: String, httpMethod: String? = nil, baseURLString: String? = nil) -> URLRequest? {

    guard
      let url = URL(string: baseURLString ?? Constants.defaultApiBaseURLString),
      let baseURL = URL(string: path, relativeTo: url)
    else { return nil }

    var request = URLRequest(url: baseURL)
    request.httpMethod = httpMethod ?? Constants.getMethodString

    if let token = storage.token {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    return request
  }
}
