//
//  ImageListTests.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 24.09.2023.
//

@testable import ImageFeed_ios
import XCTest

final class ImageListTests: XCTestCase {

  let viewController = ImagesListViewController()
  let presenter = ImageListPresenterSpy()
  let indexPath = IndexPath(row: 1, section: 0)

  override func setUpWithError() throws {
    // given
    viewController.presenter = presenter
    presenter.view = viewController
  }

  func testViewControllerCallViewDidLoad() {
    // when
    _ = viewController.view

    // then
    XCTAssertTrue(presenter.viewDidLoadCalled)
  }

  func testUpdateTableViewAnimated() {
    // when
    _ = viewController.view
    presenter.updateTableViewAnimated()

    // then
    XCTAssertTrue(presenter.updateTableViewAnimatedCalled)
  }

  func testCalcHeightForRowAt() {
    // when
    _ = viewController.view
    let result = presenter.calcHeightForRowAt(indexPath: indexPath)

    // then
    XCTAssertTrue(presenter.calcHeightForRowAtCalled)
    XCTAssertTrue(presenter.calcHeightForRowAtGotIndex)
    XCTAssertEqual(result, CGFloat(100))
  }

  func testCheckNeedLoadNextPhotos() {
    // when
    _ = viewController.view
    presenter.checkNeedLoadNextPhotos(indexPath: indexPath)

    // then
    XCTAssertTrue(presenter.checkNeedLoadNextPhotosCalled)
    XCTAssertTrue(presenter.checkNeedLoadNextPhotosGotIndex)
  }

  func testReturnPhotoModelAt() {
    // when
    _ = viewController.view
    _ = presenter.returnPhotoModelAt(indexPath: indexPath)

    // then
    XCTAssertTrue(presenter.returnPhotoModelAtCalled)
    XCTAssertTrue(presenter.returnPhotoModelAtGotIndex)
  }
}
