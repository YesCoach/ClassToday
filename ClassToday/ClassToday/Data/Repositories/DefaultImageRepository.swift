//
//  DefaultImageRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import UIKit

final class DefaultImageRepository {

    private let storageManager: StorageManager

    init(storageManager: StorageManager = StorageManager.shared) {
        self.storageManager = storageManager
    }
}

extension DefaultImageRepository: ImageRepository {
    func upload(image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {
        storageManager.upload(image: image, completion: completion)
    }

    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        storageManager.downloadImage(urlString: urlString, completion: completion)
    }

    func deleteImage(urlString: String, completion: @escaping () -> ()) {
        storageManager.deleteImage(urlString: urlString, completion: completion)
    }
}
