//
//  ImageFeed_iosTests.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 21.09.2023.
//

// swiftlint:disable force_cast

@testable import ImageFeed_ios
import XCTest

final class WebViewTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testViewControllerCallsViewDidLoad() {

    // given
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateViewController(
      withIdentifier: "WebViewViewControllerID"
    ) as! WebViewViewController
    let presenter = WebViewPresenterSpy()
    viewController.presenter = presenter
    presenter.view = viewController

    // when
    _ = viewController.view

    // then
    XCTAssertTrue(presenter.viewDidLoadCalled)
  }

  func testPresenterCallsLoadRequest() {

    // given
    let viewController = WebViewViewControllerSpy()
    let authHelper = AuthHelper()
    let presenter = WebViewPresenter(authHelper: authHelper)
    viewController.presenter = presenter
    presenter.view = viewController

    // when
    presenter.viewDidLoad()

    // then
    XCTAssertTrue(viewController.viewDidLoadRequest)
  }
}
// swiftlint:enable force_cast
