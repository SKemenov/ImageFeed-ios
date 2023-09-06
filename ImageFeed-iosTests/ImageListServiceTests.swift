//
//  ImageListServiceTests.swift
//  ImageListServiceTestsTests
//
//  Created by Sergey Kemenov on 06.09.2023.
//

import XCTest
@testable import ImageFeed_ios

final class ImageListServiceTests: XCTestCase {
  func testFetchPhotos() {
    let service = ImageListService.shared
    let expectation = self.expectation(description: "Wait for Notification")
    NotificationCenter.default.addObserver(
      forName: ImageListService.didChangeNotification,
      object: nil,
      queue: .main) { _ in
      expectation.fulfill()
    }

    service.fetchPhotosNextPage()
    wait(for: [expectation], timeout: 10)
    XCTAssertEqual(service.photos.count, 10)
  }
}
