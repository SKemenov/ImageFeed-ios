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

  private let photosName: [String] = Array(0..<20).map { "\($0)" }
  private let showSingleImageSegueIdentifier = "ShowSingleImage"

  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }()

  // MARK: - Public properties

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
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
      let image = UIImage(named: photosName[indexPath.row])
      viewController.image = image
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
    photosName.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let image = UIImage(named: photosName[indexPath.row]) else {
      return 0
    }
    let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
    let imageWidth = image.size.width
    let scale = imageViewWidth / imageWidth
    let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
    return cellHeight
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ImagesListCell.reuseIdentifier,
      for: indexPath
    ) as? ImagesListCell else {
      return UITableViewCell()
    }

    // prepare data for ImagesListCell. TO-DO: extract it into structure next sprint
    let image = UIImage(named: photosName[indexPath.row])
    let date = dateFormatter.string(from: Date())
    let isLiked = indexPath.row % 2 == 0

    // Best practics: Denis showed how to extract this method into ImagesListCell class and used from there
    cell.config(image: image, date: date, isLiked: isLiked)

    return cell
  }
}
