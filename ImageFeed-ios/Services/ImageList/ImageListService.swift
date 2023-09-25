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
    lastLoadedPage = nil
    photos = []
  }

  func fetchPhotosNextPage() {
    assert(Thread.isMainThread)
    print("ITS LIT ILS 131 Run fetchPhotosNextPage()")

    guard currentPhotosTask == nil else {
      print("ITS LIT ILS 134 Race Condition - reject repeated photos request")
      return
    }
    let nextPage = makeNextPageNumber()
    fetchPhotosCount += 1
    print("ITS LIT ILS 139 fetchPhotosCount: \(fetchPhotosCount)")


    guard let request = makePhotosListRequest(page: nextPage) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
      guard let self else { preconditionFailure("ITS LIT ILS Cannot make weak link") }
      DispatchQueue.main.async {
        switch result {
        case .success(let photoResults):
          // var photos: [Photo] = []
          photoResults.forEach { photo in
            self.photos.append(self.convert(result: photo))
          }
          // self.photos += photos
          self.lastLoadedPage = nextPage
          NotificationCenter.default.post(
            name: ImageListService.didChangeNotification,
            object: self,
            userInfo: ["Photos": self.photos]
          )
          self.currentPhotosTask = nil
        case .failure(let error):
          print("ITS LIT ILS 102 \(String(describing: error))")
        }
      }
    }
    currentPhotosTask = task
    task.resume()
  }
}
