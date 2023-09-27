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
  func changeLike(photoId: String, indexPath: IndexPath, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void)
}

// MARK: - Class

final class ImageListService {
  // MARK: - Private stored properties
  static let shared = ImageListService()
  static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

  private let session = URLSession.shared
  private let requestBuilder = URLRequestBuilder.shared
  private let imagesPerPage = 10

  private var currentPhotosTask: URLSessionTask?
  private var currentLikeTask: URLSessionTask?
  private var fetchPhotosCount = 0
  private var lastLoadedPage: Int?
  private (set) var photos: [Photo] = []

  private init() { }
}

// MARK: - Private methods

private extension ImageListService {

  func makeLikeRequest(for id: String, with method: String) -> URLRequest? {
    requestBuilder.makeHTTPRequest(path: "/photos/\(id)/like", httpMethod: method)
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

  func convert(result photoResult: PhotoResult) -> Photo {
    let thumbWidth = 200.0
    let aspectRatio = Double(photoResult.width) / Double(photoResult.height)
    let thumbHeight = thumbWidth / aspectRatio
    return Photo(
      id: photoResult.id,
      size: CGSize(width: Double(photoResult.width), height: Double(photoResult.height)),
      createdAt: ISO8601DateFormatter().date(from: photoResult.createdAt ?? ""),
      welcomeDescription: photoResult.description,
      thumbImageURL: photoResult.urls.small,
      largeImageURL: photoResult.urls.full,
      isLiked: photoResult.likedByUser,
      thumbSize: CGSize(width: thumbWidth, height: thumbHeight)
    )
  }
}

// MARK: - ImageListLoading

extension ImageListService: ImageListLoading {

  func changeLike(photoId: String, indexPath: IndexPath, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
    assert(Thread.isMainThread)
    if currentLikeTask != nil { return }
    currentLikeTask?.cancel()
    let method = isLike ? Constants.postMethodString : Constants.deleteMethodString

    guard let request = makeLikeRequest(for: photoId, with: method) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    let task = session.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.currentLikeTask = nil
        switch result {
        case .success(let photoLiked):
          let likedByUser = photoLiked.photo.likedByUser
          self.photos[indexPath.row].isLiked = likedByUser
          completion(.success(likedByUser))

        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
    self.currentLikeTask = task
    task.resume()
  }

  func resetPhotos() {
    lastLoadedPage = nil
    photos = []
  }

  func fetchPhotosNextPage() {
    assert(Thread.isMainThread)
    if currentPhotosTask != nil { return }
    currentPhotosTask?.cancel()

    let nextPage = makeNextPageNumber()
    fetchPhotosCount += 1


    guard let request = makePhotosListRequest(page: nextPage) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
      guard let self else { preconditionFailure("ITS LIT ILS Cannot make weak link") }
      DispatchQueue.main.async {
        self.currentPhotosTask = nil
        switch result {
        case .success(let photoResults):
          var photos: [Photo] = []
          photoResults.forEach { photo in
            photos.append(self.convert(result: photo))
          }
          self.photos += photos
          self.lastLoadedPage = nextPage
          NotificationCenter.default.post(
            name: ImageListService.didChangeNotification,
            object: self,
            userInfo: ["Photos": self.photos]
          )
        case .failure(let error):
          print("ITS LIT ILS 102 \(String(describing: error))")
        }
      }
    }
    currentPhotosTask = task
    task.resume()
  }
}
