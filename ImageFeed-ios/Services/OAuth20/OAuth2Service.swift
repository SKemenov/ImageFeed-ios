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
  // MARK: - Private properties

  private let urlSession: URLSession
  private let storage: OAuth2TokenStorage
  private let requestBuilder: URLRequestBuilder

  private var currentTask: URLSessionTask?
  private var lastCode: String?

  // MARK: - Singleton property & init

  static let shared = OAuth2Service()

  private init(
    urlSession: URLSession = .shared,
    storage: OAuth2TokenStorage = .shared,
    requestBuilder: URLRequestBuilder = .shared
  ) {
    self.urlSession = urlSession
    self.storage = storage
    self.requestBuilder = requestBuilder
  }

  var isAuthenticated: Bool {
    storage.token != nil
  }
}

// MARK: - Private enums, property & structure

private extension OAuth2Service {
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

  func makeAuthTokenRequest(with code: String) -> URLRequest? {
    return requestBuilder.makeHTTPRequest(
      path: Constants.tokenRequestPathString
      + "?client_id=\(AuthConfiguration.standard.accessKey)"
      + "&&client_secret=\(AuthConfiguration.standard.secretKey)"
      + "&&redirect_uri=\(AuthConfiguration.standard.redirectURI)"
      + "&&code=\(code)"
      + "&&grant_type=\(Constants.tokenRequestGrantTypeString)",
      httpMethod: Constants.postMethodString,
      baseURLString: AuthConfiguration.standard.baseURLString)
  }
}

// MARK: - AuthRouting

extension OAuth2Service: AuthRouting {

  func fetchAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {

    assert(Thread.isMainThread)
    guard code != lastCode else { return }
    currentTask?.cancel()
    lastCode = code

    guard let request = makeAuthTokenRequest(with: code) else {
      assertionFailure("Invalid request")
      completion(.failure(NetworkError.invalidRequest))
      return
    }

    currentTask = urlSession.objectTask(for: request) {
      [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
      guard let self else { preconditionFailure("Cannot make weak link") }
      self.currentTask = nil
      switch result {
      case .success(let body):
        let authToken = body.accessToken
        self.storage.token = authToken
        completion(.success(authToken))
      case .failure(let error):
        self.lastCode = nil
        completion(.failure(error))
      }
    }
  }
}
