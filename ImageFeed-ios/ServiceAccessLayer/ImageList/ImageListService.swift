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
}

// MARK: - Class

final class ImageListService {
  // MARK: - Private stored properties
  static let shared = ImageListService()
  static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

  private let session = URLSession.shared
  private let requestBuilder = URLRequestBuilder.shared

  private var currentTask: URLSessionTask?

  private var imagesPerPage = 10
  private var lastLoadedPage: Int?
//  private var lastLoadedPage: Int {
//    photos.count / imagesPerPage
//  }

  private (set) var photos: [Photo] = [] {
    didSet {
      NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: self)
      print("ITS LIT ILS 36 photos.count \(photos.count)")
    }
  }

  private init() { }
}

// MARK: - Private methods

private extension ImageListService {

  func makePhotoRequest(id: String) -> URLRequest? {
    let request = requestBuilder.makeHTTPRequest(path: "/photos/\(id)")
    // FIXME: Remove before PR Sprint 12
    print("ITS LIT ILS 49 \(String(describing: request))")
    return request
  }

  func makePhotosListRequest(page: Int) -> URLRequest? {
    var request = requestBuilder.makeHTTPRequest(path: "/photos")
    request?.setValue("\(page)", forHTTPHeaderField: "page")
    request?.setValue("\(imagesPerPage)", forHTTPHeaderField: "per_page")
    print("ITS LIT ILS 57 request.header.page # \(String(describing: request?.value(forHTTPHeaderField: "page")))")
    return request
    //   Parameters
    //    param     Description
    //    page      Page number to retrieve. (Optional; default: 1)
    //    per_page  Number of items per page. (Optional; default: 10)
    //    order_by  How to sort the photos. Optional. (Valid values: latest, oldest, popular; default: latest)
  }

  func makeNextPageNumber() -> Int {
    guard let lastLoadedPage else { return 1 }
    return lastLoadedPage + 1
  }
}

// MARK: - ImageListLoading

extension ImageListService: ImageListLoading {

  func fetchPhotosNextPage() {
//    print("ITS LIT ILS 72 \(String(describing: currentTask))")

    assert(Thread.isMainThread)
//    print("ITS LIT ILS 75 \(String(describing: lastLoadedPage))")
//    print("ITS LIT ILS 76 photos.count \(photos.count)")

    guard currentTask == nil else {
      print("ITS LIT ILS 79 Race Condition - reject repeated photos request")
      return
    }

    let nextPage = makeNextPageNumber()
    print("ITS LIT ILS 84 nextPage \(nextPage)")

    guard let request = makePhotosListRequest(page: nextPage) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    print("ITS LIT ILS 92 \(request)")

    let task = session.objectTask(for: request) {
      [weak self] (result: Result<[PhotoResult], Error>) in

      guard let self else { preconditionFailure("Cannot make weak link") }

//      print("ITS LIT ILS 99 \(String(describing: self.currentTask))")
//      print("ITS LIT ILS 100 \(result)")

      switch result {
      case .success(let photoResults):
//        print("ITS LIT ILS 104 \(photoResults)")

        DispatchQueue.main.async {
          var photos: [Photo] = []
          photoResults.forEach { photo in
            photos.append(self.convert(result: photo))
            print("ITS LIT ILS 116 append .photos.ID \(photo.id)")
          }
          print("ITS LIT ILS 111 photos.count \(photos.count)")
          self.photos += photos
          self.photos.forEach { photo in
            print("ITS LIT ILS 121 self.photos.ID \(photo.id)")
          }
          self.lastLoadedPage = nextPage
          print("ITS LIT ILS 114 self.lastLoadedPage \(String(describing: self.lastLoadedPage))")
        }
        print("ITS LIT ILS 116 lastLoadedPage \(String(describing: lastLoadedPage))")
        print("ITS LIT ILS 117 self.photos.count \(self.photos.count)")
        print("ITS LIT ILS 118 done decode photos")
      case .failure(let error):
        print("ITS LIT ILS 120 \(String(describing: error))")
      }
      self.currentTask = nil
      print("ITS LIT ILS 123 self.currentTask \(String(describing: self.currentTask))")
      print("ITS LIT ILS 124 self.photos.count \(self.photos.count)")
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
