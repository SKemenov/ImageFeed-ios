//
//  URLSession+Extensions.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 12.08.2023.
//

import Foundation

// MARK: - Enum

// TODO: check to make it private
enum NetworkError: Error {
  case httpStatusCode(Int)
  case urlRequestError(Error)
  case urlSessionError
  case decodingError(Error)
  case invalidRequest
}

// MARK: - Public methods

extension URLSession {
  func objectTask<T: Decodable>(
    for request: URLRequest,
    completion: @escaping (Result<T, Error>) -> Void
  ) -> URLSessionTask {
    let completionOnMainQueue: (Result<T, Error>) -> Void = { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }

    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
      if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
        if 200..<300 ~= statusCode {
          do {
            let decoder = SnakeCaseJSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            completionOnMainQueue(.success(result))
          } catch {
            completionOnMainQueue(.failure(NetworkError.decodingError(error)))
          }
        } else {
          completionOnMainQueue(.failure(NetworkError.httpStatusCode(statusCode)))
        }
      } else if let error {
        completionOnMainQueue(.failure(NetworkError.urlRequestError(error)))
      } else {
        completionOnMainQueue(.failure(NetworkError.urlSessionError))
      }
    }

    task.resume()
    return task
  }
}
