//
//  AlertPresenter.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 29.08.2023.
//

import UIKit

// MARK: - Protocol

protocol AlertPresenting: AnyObject {
  func showAlert(title: String, message: String, completion: @escaping () -> Void)
}

// MARK: - Class

final class AlertPresenter: AlertPresenting {

  weak var delegate: UIViewController?

  func showAlert(title: String, message: String, completion: @escaping () -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
      completion()
    }
    alert.addAction(alertAction)
    delegate?.present(alert, animated: true)
  }
}
