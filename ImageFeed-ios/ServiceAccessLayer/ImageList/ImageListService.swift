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
    guard currentLikeTask == nil else { return }
    let method = isLike ? Constants.postMethodString : Constants.deleteMethodString

    guard let request = makeLikeRequest(for: photoId, with: method) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    let task = session.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        switch result {
        case .success(let photoLiked):
          let likedByUser = photoLiked.photo.likedByUser
          // if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
          //  let photo = self.photos[index]
          //  let newPhoto = Photo(
          //    id: photo.id,
          //    size: photo.size,
          //    createdAt: photo.createdAt,
          //    welcomeDescription: photo.welcomeDescription,
          //    thumbImageURL: photo.thumbImageURL,
          //    largeImageURL: photo.largeImageURL,
          //    isLiked: likedByUser,
          //    thumbSize: photo.thumbSize
          //  )
          //  self.photos[index] = newPhoto
          // }
          self.photos[indexPath.row].isLiked = likedByUser
          completion(.success(likedByUser))
          self.currentLikeTask = nil

        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
    currentLikeTask = task
    task.resume()
  }

  func resetPhotos() {
    photos = []
  }

  func fetchPhotosNextPage() {
    assert(Thread.isMainThread)

    guard currentPhotosTask == nil else {
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
      guard let self else { preconditionFailure("ITS LIT ILS Cannot make weak link") }
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
      self.currentPhotosTask = nil
    }
    currentPhotosTask = task
    task.resume()
  }
}
