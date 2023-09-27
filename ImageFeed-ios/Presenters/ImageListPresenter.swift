//
//  ImageListPresenter.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 23.09.2023.
//

import Foundation
import Kingfisher

// MARK: - Protocol

public protocol ImageListPresenterProtocol {
  var view: ImagesListViewControllerProtocol? { get set }
  var photosTotalCount: Int { get }
  func viewDidLoad()
  func updateTableViewAnimated()
  func calcHeightForRowAt(indexPath: IndexPath) -> CGFloat
  func checkNeedLoadNextPhotos (indexPath: IndexPath)
  func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath)
  func returnPhotoModelAt (indexPath: IndexPath) -> Photo?
}

// MARK: - Class

final class ImageListPresenter {
  // MARK: - Private properties

  private var imageListService = ImageListService.shared

  // MARK: - Public properties

  weak var view: ImagesListViewControllerProtocol?
  var photos: [Photo] = []
  var photosTotalCount: Int {
    photos.count
  }
}

// MARK: - Private methods

private extension ImageListPresenter {

  func setupKfCache() {
    let cache = ImageCache.default
    cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
    cache.memoryStorage.config.countLimit = 150
    cache.diskStorage.config.sizeLimit = 1024 * 1024 * 1024
    cache.memoryStorage.config.expiration = .seconds(600)
    cache.diskStorage.config.expiration = .days(10)
    cache.memoryStorage.config.cleanInterval = 300
  }
}

// MARK: - Public methods

// non-private for unit tests
extension ImageListPresenter {
  func setupImageListService() {
    imageListService.fetchPhotosNextPage()
  }
}

// MARK: - ImageListPresenterProtocol

extension ImageListPresenter: ImageListPresenterProtocol {

  func viewDidLoad() {
    view?.setupTableView()
    setupImageListService()
    setupKfCache()
  }

  func updateTableViewAnimated() {
    let oldCount = photosTotalCount
    photos = imageListService.photos
    let newCount = photosTotalCount
    if oldCount != newCount {
      view?.tableView.performBatchUpdates {
        let indexes = (oldCount..<newCount).map { index in
          IndexPath(row: index, section: 0)
        }
        view?.tableView.insertRows(at: indexes, with: .automatic)
      }
    }
  }

  func checkNeedLoadNextPhotos (indexPath: IndexPath) {
    if indexPath.row + 2 == photosTotalCount {
      imageListService.fetchPhotosNextPage()
    }
  }

  func returnPhotoModelAt (indexPath: IndexPath) -> Photo? {
    photos[indexPath.row]
  }

  func calcHeightForRowAt(indexPath: IndexPath) -> CGFloat {
    guard let view else { return 0 }
    let imageInsets = (top: CGFloat(4), left: CGFloat(16), bottom: CGFloat(4), right: CGFloat(16))
    let thumbImageSize = photos[indexPath.row].thumbSize
    let imageViewWidth = view.tableView.bounds.width - imageInsets.left - imageInsets.right
    let imageWidth = thumbImageSize.width
    let scale = imageViewWidth / imageWidth
    let cellHeight = thumbImageSize.height * scale + imageInsets.top + imageInsets.bottom
    return cellHeight
  }

  func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
    let photo = photos[indexPath.row]
    UIBlockingProgressHUD.show()
    imageListService.changeLike(photoId: photo.id, indexPath: indexPath, isLike: !photo.isLiked) { [weak self ] result in
      guard let self else { return }
      switch result {
      case .success(let isLiked):
        self.photos[indexPath.row].isLiked = isLiked
        cell.setIsLiked(isLiked)
        UIBlockingProgressHUD.dismiss()
      case .failure(let error):
        UIBlockingProgressHUD.dismiss()
        print("\(error.localizedDescription)")
      }
    }
  }
}
