//
//  AlertPresenter.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 29.08.2023.
//

import UIKit

// MARK: - Protocol

protocol AlertPresenting: AnyObject {
  func showAlert(for result: AlertModel)
}

// MARK: - Class

final class AlertPresenter {

  private weak var viewController: UIViewController?

  init(viewController: UIViewController?) {
    self.viewController = viewController
  }
}

// MARK: - AlertPresenting

extension AlertPresenter: AlertPresenting {

  func showAlert(for result: AlertModel) {
    let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: result.buttonText, style: .default) { _ in
      result.completion?()
      print("ITS LIT in alert Action")
    }
    alert.addAction(alertAction)
    viewController?.present(alert, animated: true)
  }
}
