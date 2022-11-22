//
//  ImageUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import UIKit

protocol ImageUseCase {
    func upload(image: UIImage, completion: @escaping (Result<String, Error>) -> ())
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> ())
    func deleteImage(urlString: String, completion: @escaping() -> ())}

final class DefaultImageUseCase: ImageUseCase {

    private let imageRepository: ImageRepository

    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    func upload(image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {
        imageRepository.upload(image: image, completion: completion)
    }

    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        imageRepository.downloadImage(urlString: urlString, completion: completion)
    }

    func deleteImage(urlString: String, completion: @escaping () -> ()) {
        imageRepository.deleteImage(urlString: urlString, completion: completion)
    }
}
