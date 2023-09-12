//
//  ImageListService.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 04.09.2023.
//

import Foundation

// MARK: - Protocol

protocol ImageListLoading: AnyObject {
  func fetchPhotosNextPage()
  func resetPhotos()
}

// MARK: - Class

final class ImageListService {
  // MARK: - Private stored properties
  static let shared = ImageListService()
  static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

  private let session = URLSession.shared
  private let requestBuilder = URLRequestBuilder.shared
  private let imagesPerPage = 10

  private var currentTask: URLSessionTask?
  private var lastLoadedPage: Int?
  private (set) var photos: [Photo] = []

  private init() { }
}

// MARK: - Private methods

private extension ImageListService {

  func makePhotoRequest(id: String) -> URLRequest? {
    let request = requestBuilder.makeHTTPRequest(path: "/photos/\(id)")
    // FIXME: Remove prints before PR Sprint 12
    print("ITS LIT ILS 46 \(String(describing: request))")
    return request
  }

  func makePhotosListRequest(page: Int) -> URLRequest? {
    requestBuilder.makeHTTPRequest(
      path: "/photos"
      + "?page=\(page)"
      + "&&per_page=\(imagesPerPage)"
    )
  }

  func makeNextPageNumber() -> Int {
    guard let lastLoadedPage else { return 1 }
    return lastLoadedPage + 1
  }
}

// MARK: - ImageListLoading

extension ImageListService: ImageListLoading {

  func resetPhotos() {
    photos = []
  }

  func fetchPhotosNextPage() {

    assert(Thread.isMainThread)

    guard currentTask == nil else {
      print("ITS LIT ILS 77 Race Condition - reject repeated photos request")
      return
    }

    let nextPage = makeNextPageNumber()

    guard let request = makePhotosListRequest(page: nextPage) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
      guard let self else { preconditionFailure("Cannot make weak link") }
      switch result {
      case .success(let photoResults):
        DispatchQueue.main.async {
          var photos: [Photo] = []
          photoResults.forEach { photo in
            photos.append(self.convert(result: photo))
          }
          self.photos += photos
          NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: self)
          self.lastLoadedPage = nextPage
        }
      case .failure(let error):
        print("ITS LIT ILS 102 \(String(describing: error))")
      }
      self.currentTask = nil
    }
    self.currentTask = task
    task.resume()
  }
}

// MARK: - Make Photo from PhotoResult's data

private extension ImageListService {
  func convert(result photoResult: PhotoResult) -> Photo {
    let thumbWidth = 200.0
    let aspectRatio = Double(photoResult.width) / Double(photoResult.height)
    let thumbHeight = thumbWidth / aspectRatio
    return Photo(
      id: photoResult.id,
      size: CGSize(width: Double(photoResult.width), height: Double(photoResult.height)),
      createdAt: ISO8601DateFormatter().date(from: photoResult.createdAt ?? ""),
      welcomeDescription: photoResult.description,
      thumbImageURL: photoResult.urls.thumb,
      largeImageURL: photoResult.urls.full,
      isLiked: photoResult.likedByUser,
      thumbSize: CGSize(width: thumbWidth, height: thumbHeight)
    )
  }
}
