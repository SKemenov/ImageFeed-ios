//
//  OAuth2Service.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 09.08.2023.
//

import Foundation

// MARK: - Protocol

protocol AuthRouting: AnyObject {
  func fetchAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void)
}

// MARK: - Class

final class OAuth2Service {
  static let shared = OAuth2Service()
  private let urlSession = URLSession.shared
}

// MARK: - Private enums, property & structure

private extension OAuth2Service {
  enum OAuth2Constants {
    static let tokenURLString = "https://unsplash.com/oauth/token"
    static let tokenRequestURLString = "https://unsplash.com"
    static let tokenRequestPathString = "/oauth/token"
    static let tokenRequestMethodString = "POST"
    static let tokenRequestGrantTypeString = "authorization_code"
  }

  enum NetworkError: Error {
    case codeError
  }

  var authToken: String? {
    get {
      print("ITS LIT Read OAuth2Service.authToken")
      return OAuth2TokenStorage().token
    }
    set {
      print("ITS LIT Write OAuth2Service.authToken")
      OAuth2TokenStorage().token = newValue
    }
  }

  // TODO: Use SnakeCaseJSONDecoder instead of SJONDecoder with CodingKeys enum
  struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
  }
}

// MARK: - Private methods

private extension OAuth2Service {
  func fetchOAuthTokenResponseBody(
    for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
  ) -> URLSessionTask {
    let decoder = SnakeCaseJSONDecoder()
    return urlSession.fetchData(for: request) { (result: Result<Data, Error>) in
      let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
        Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
      }
      print("ITS LIT fetchOAuthTokenResponseBody \(response)")
      completion(response)
    }
  }

  func authTokenRequest(code: String) -> URLRequest {
    guard let url = URL(string: OAuth2Constants.tokenRequestURLString) else { preconditionFailure("Cannot make url") }
    return URLRequest.makeHTTPRequest(
      path: OAuth2Constants.tokenRequestPathString
      + "?client_id=\(accessKey)"
      + "&&client_secret=\(secureKey)"
      + "&&redirect_uri=\(redirectURI)"
      + "&&code=\(code)"
      + "&&grant_type=\(OAuth2Constants.tokenRequestGrantTypeString)",
      httpMethod: OAuth2Constants.tokenRequestMethodString,
      baseURL: url)
  }
}

// MARK: - AuthRouting

extension OAuth2Service: AuthRouting {
  func fetchAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
    let request = authTokenRequest(code: code)
    let task = fetchOAuthTokenResponseBody(for: request) { [weak self] result in
      guard let self else { preconditionFailure("Cannot make weak link") }
      switch result {
      case .success(let body):
        print("ITS LIT OAuth2Service.fetchAuthToken.success")
        self.authToken = body.accessToken
        completion(.success(body.accessToken))
      case .failure(let error):
        completion(.failure(error))
      }
    }
    task.resume()
  }
}
