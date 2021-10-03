//
//  ImageLoaderService.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 29/09/21.
//

import Foundation
import Combine
import UIKit

protocol ImageLoaderServiceType: AnyObject {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoaderService: ImageLoaderServiceType {

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in return UIImage(data: data) }
            .catch { error in return Just(nil) }
            .print("Image loading \(url):")
            .eraseToAnyPublisher()
    }
}

//https://developer.apple.com/documentation/uikit/views_and_controls/table_views/asynchronously_loading_images_into_table_and_collection_views
