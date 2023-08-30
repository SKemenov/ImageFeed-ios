//
//  ProfileService.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 28.08.2023.
//

import Foundation

// MARK: - Protocol

protocol ProfileLoading: AnyObject {
  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
}

// MARK: - Class

final class ProfileService {
  // MARK: - Private stored properties
  static let shared = ProfileService()

  private let urlSession: URLSession
  private let requestBuilder: URLRequestBuilder

  private var currentTask: URLSessionTask?
  private (set) var profile: Profile?

  init(urlSession: URLSession = .shared, requestBuilder: URLRequestBuilder = .shared) {
    self.urlSession = urlSession
    self.requestBuilder = requestBuilder
  }
}

// MARK: - Private methods

private extension ProfileService {
  func makeProfileRequest() -> URLRequest? {
    requestBuilder.makeHTTPRequest(path: Constants.profileRequestPathString)
  }
}

// MARK: - ProfileLoading

extension ProfileService: ProfileLoading {
  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    assert(Thread.isMainThread)
    currentTask?.cancel()

    guard let request = makeProfileRequest() else {
      assertionFailure("Invalid request")
      completion(.failure(NetworkError.invalidRequest))
      return
    }

    let session = URLSession.shared
    currentTask = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
      guard let self else { preconditionFailure("Cannot make weak link") }
      self.currentTask = nil
      switch result {
      case .success(let profileResult):
        let profile = Profile(result: profileResult)
        self.profile = profile
        completion(.success(profile))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
