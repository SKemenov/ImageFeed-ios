//
//  WebViewTests.swift
//  ImageFeed-iosTests
//
//  Created by Sergey Kemenov on 21.09.2023.
//

// swiftlint:disable force_cast force_unwrapping

@testable import ImageFeed_ios
import XCTest

final class WebViewTests: XCTestCase {

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

  func testProgressVisibleWhenLessThenOne() {
    // given
    let authHelper = AuthHelper()
    let presenter = WebViewPresenter(authHelper: authHelper)
    let progress: Float = 0.6

    // when
    let shouldHideProgress = presenter.shouldHideProgress(for: progress)

    // then
    XCTAssertFalse(shouldHideProgress)
  }

  func testProgressHiddenWhenOne() {
    // given
    let authHelper = AuthHelper()
    let presenter = WebViewPresenter(authHelper: authHelper)
    let progress: Float = 1

    // when
    let shouldHideProgress = presenter.shouldHideProgress(for: progress)

    // then
    XCTAssertTrue(shouldHideProgress)
  }
  func testAuthHelperAuthURL() {
    // given
    let configuration = AuthConfiguration.standard
    let authHelper = AuthHelper(configuration: configuration)

    // when
    let url = authHelper.authURL()
    let urlString = url.absoluteString

    // then
    XCTAssertTrue(urlString.contains(configuration.authURLString))
    XCTAssertTrue(urlString.contains(configuration.accessKey))
    XCTAssertTrue(urlString.contains(configuration.redirectURI))
    XCTAssertTrue(urlString.contains("code"))
    XCTAssertTrue(urlString.contains(configuration.accessSCope))
  }

  func testCodeFromURL() {
    // given
    let authHelper = AuthHelper()
    let token = "test-code"
    var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
    urlComponents.queryItems = [ URLQueryItem(name: "code", value: token) ]
    let url = urlComponents.url!

    // when
    let returnedToken = authHelper.code(from: url)

    // then
    XCTAssertEqual(token, returnedToken)
  }
}

// swiftlint:enable force_cast force_unwrapping
