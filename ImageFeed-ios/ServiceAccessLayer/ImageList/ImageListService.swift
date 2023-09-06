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
  private var lastLoadedPage: Int {
    photos.count / imagesPerPage
  }

  private (set) var photos: [Photo] = [] {
    didSet {
      NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: self)
    }
  }

  private init() { }
}

// MARK: - Private methods

private extension ImageListService {

  func makePhotoRequest(id: String) -> URLRequest? {
    let request = requestBuilder.makeHTTPRequest(path: "/photos/\(id)")
    // FIXME: Remove before PR Sprint 12
    print("ITS LIT ILS 40 \(String(describing: request))")
    return request
  }

  func makePhotosListRequest(page: Int) -> URLRequest? {
    var request = requestBuilder.makeHTTPRequest(path: "/photos")
    request?.setValue("\(page)", forHTTPHeaderField: "page")
    request?.setValue("\(imagesPerPage)", forHTTPHeaderField: "per_page")
    print("ITS LIT ILS 47 \(String(describing: request))")
    return request
//   Parameters
//    param     Description
//    page      Page number to retrieve. (Optional; default: 1)
//    per_page  Number of items per page. (Optional; default: 10)
//    order_by  How to sort the photos. Optional. (Valid values: latest, oldest, popular; default: latest)
  }
}

// MARK: - ImageListLoading

extension ImageListService: ImageListLoading {

  func fetchPhotosNextPage() {
    print("ITS LIT ILS 66 \(String(describing: currentTask))")

    assert(Thread.isMainThread)
    print("ITS LIT ILS 69 \(String(describing: lastLoadedPage))")
    print("ITS LIT ILS 70 \(photos)")

    guard currentTask == nil else {
      print("ITS LIT ILS 73 reject repeated photos request")
      return
    }

    let nextPage = lastLoadedPage + 1

    guard let request = makePhotosListRequest(page: nextPage) else {
      assertionFailure("Invalid request")
      print(NetworkError.invalidRequest)
      return
    }

    print("ITS LIT ILS 81 \(request)")

    let task = session.objectTask(for: request) {
      [weak self] (result: Result<[PhotoResult], Error>) in

      guard let self else { preconditionFailure("Cannot make weak link") }

      print("ITS LIT ILS 87 \(String(describing: self.currentTask))")
      print("ITS LIT ILS 90 \(result)")

      switch result {
      case .success(let photoResults):
        print("ITS LIT ILS 94 \(photoResults)")

        DispatchQueue.main.async {
          var photos: [Photo] = []
          photoResults.forEach { photo in
            photos.append(self.convert(result: photo))
          }
          print("ITS LIT ILS 102 \(photos)")
          self.photos += photos
          print("ITS LIT ILS 104 \(self.photos)")
          print("ITS LIT ILS 104 \(String(describing: self.lastLoadedPage))")
        }
        print("ITS LIT ILS 106 \(String(describing: lastLoadedPage))")
        print("ITS LIT ILS 107 \(self.photos)")
        print("ITS LIT ILS 107 done decode photos")
      case .failure(let error):
        print("ITS LIT ILS 110 \(String(describing: error))")
      }
      self.currentTask = nil
      print("ITS LIT ILS 114 \(String(describing: self.currentTask))")
      print("ITS LIT 115 \(self.photos)")
    }
    self.currentTask = task
    task.resume()
  }
}

// MARK: - Make Photo from PhotoResult's data

private extension ImageListService {

  func convert(result photoResult: PhotoResult) -> Photo {
    Photo(
      id: photoResult.id,
      size: CGSize(width: Double(photoResult.width), height: Double(photoResult.height)),
      createdAt: Constants.dateFormatter.date(from: photoResult.createdAt) ?? Date(), // FIXME: need to use formatter
      welcomeDescription: photoResult.description,
      thumbImageURL: photoResult.urls.thumb,
      largeImageURL: photoResult.urls.full,
      isLiked: photoResult.likedByUser
    )
  }
}
