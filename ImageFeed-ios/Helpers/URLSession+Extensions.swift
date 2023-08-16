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
}

// MARK: - Public methods

extension URLSession {
  func fetchData(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
    let completionOnMainQueue: (Result<Data, Error>) -> Void = { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }

    let task = dataTask(with: request) { data, response, error in
      if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
        if 200..<300 ~= statusCode {
          print("\nITS LIT data from URLSession \(data)")
          completionOnMainQueue(.success(data))
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
