//
//  URLRequest+Extensions.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 11.08.2023.
//

import Foundation

// MARK: - Custom URLRequest implementation

extension URLRequest {
  static func makeHTTPRequest(
    path: String,
    httpMethod: String?,
    baseURL: URL? = defaultBaseURL
  ) -> URLRequest {
    guard let url = URL(string: path, relativeTo: baseURL) else { preconditionFailure("Cannot make url") }
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    print(request)
    return request
  }
}
