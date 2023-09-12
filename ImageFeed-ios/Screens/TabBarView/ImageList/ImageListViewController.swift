//
//  ViewController.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 12.07.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
  // MARK: - Outlets

  @IBOutlet private var tableView: UITableView!

  // MARK: - Private properties

  private var photos: [Photo] = []
  private let showSingleImageSegueIdentifier = "ShowSingleImage"

  private var imageListService = ImageListService.shared
  private var imageListServiceObserver: NSObjectProtocol?

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    alertPresenter = AlertPresenter(viewController: self)
    setupTableView()
    setupImageListService()
    setupNotificationObserver()
  }
  // MARK: - public methods

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == showSingleImageSegueIdentifier {
      guard
        let viewController = segue.destination as? SingleImageViewController,
        let indexPath = sender as? IndexPath
      else {
        super.prepare(for: segue, sender: sender)
        return
      }
      viewController.largeImageURL = URL(string: photos[indexPath.row].largeImageURL)
    } else {
      super.prepare(for: segue, sender: sender)
    }
  }
}

// MARK: - private methods

private extension ImagesListViewController {

  func setupTableView() {

    tableView.dataSource = self
    tableView.delegate = self
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
  }

  func setupImageListService() {
    imageListService.fetchPhotosNextPage()
    updateTableViewAnimated()
  }

  func setupNotificationObserver() {
    imageListServiceObserver = NotificationCenter.default
      .addObserver(
        forName: ImageListService.didChangeNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.updateTableViewAnimated()
      }
  }

  func updateTableViewAnimated() {
    print("ITS LIT ILVC 89 run updateTableViewAnimated()")
    let oldCount = photos.count
    photos = imageListService.photos
    let newCount = photos.count
    print("ITS LIT ILVC 93 oldCount \(oldCount) newCount \(newCount)")

    if oldCount != newCount {
      tableView.performBatchUpdates {
        let indexes = (oldCount..<newCount).map { index in
          IndexPath(row: index, section: 0)
        }
        tableView.insertRows(at: indexes, with: .automatic)
      }
    }
  }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
  }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("ITS LIT ILVC 139 \(photos.count)")
    return photos.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ImagesListCell.reuseIdentifier,
      for: indexPath
    ) as? ImagesListCell else {
      return UITableViewCell()
    }

    let photo = photos[indexPath.row]
//    print("ITS LIT ILVC 152 indexPath.row \(indexPath.row) \(photo)")
    let isLoadedCell = cell.loadCell(from: photo)
    if isLoadedCell {
      tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let thumbImageSize = photos[indexPath.row].thumbSize
    let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
    let imageWidth = thumbImageSize.width
    let scale = imageViewWidth / imageWidth
    let cellHeight = thumbImageSize.height * scale + imageInsets.top + imageInsets.bottom
//    print("ITS LIT ILVC 187 scale \(scale) cell #\(indexPath.row) Height \(cellHeight)")
    return cellHeight
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row + 1 == photos.count {
      print("ITS LIT ILVC 193 run loading next page of images, because indexPath.row \(indexPath.row)")
      imageListService.fetchPhotosNextPage()
    }
  }
}
