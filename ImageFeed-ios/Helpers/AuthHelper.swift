//
//  AuthHelper.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 21.09.2023.
//

import Foundation

// MARK: - Protocol

protocol AuthHelperProtocol {
  func authRequest() -> URLRequest
  func code(from url: URL) -> String?
}

// MARK: - Class

final class AuthHelper {
  // MARK: - Public properties

  let configuration: AuthConfiguration

  // MARK: - Init

  init(configuration: AuthConfiguration = .standard) {
    self.configuration = configuration
  }
}

// MARK: - Private properties & methods

private extension AuthHelper {
  enum WebElements {
    static let clientId = "client_id"
    static let redirectUri = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
  }
}

// MARK: - Public methods

extension AuthHelper {
  // non-private for unit tests
  func authURL() -> URL {
    guard var urlComponents = URLComponents(string: configuration.authURLString) else {
      preconditionFailure("AH 52 Incorrect string: \(configuration.authURLString)")
    }
    urlComponents.queryItems = [
      URLQueryItem(name: WebElements.clientId, value: configuration.accessKey),
      URLQueryItem(name: WebElements.redirectUri, value: configuration.redirectURI),
      URLQueryItem(name: WebElements.responseType, value: Constants.code),
      URLQueryItem(name: WebElements.scope, value: configuration.accessSCope)
    ]
    guard let url = urlComponents.url else {
      preconditionFailure("AH 61 Incorrect URL: \(String(describing: urlComponents.url))")
    }
    return url
  }
}

// MARK: - AuthHelperProtocol

extension AuthHelper: AuthHelperProtocol {
  func authRequest() -> URLRequest {
    URLRequest(url: authURL())
  }

  func code(from url: URL) -> String? {
    if
      let urlComponents = URLComponents(string: url.absoluteString),
      urlComponents.path == Constants.authorizedURLPath,
      let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == Constants.code }) {
      return codeItem.value
    } else {
      return nil
    }
  }
}
