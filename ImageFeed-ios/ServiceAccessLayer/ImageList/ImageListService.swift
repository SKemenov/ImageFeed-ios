//
//  ImageListService.swift
//  ImageFeed-ios
//
//  Created by Sergey Kemenov on 04.09.2023.
//

import Foundation

protocol ImageListLoading: AnyObject {
  func fetchPhotosNextPage()
}

final class ImageListService {
  var lastLoadedPage: Int?
}
