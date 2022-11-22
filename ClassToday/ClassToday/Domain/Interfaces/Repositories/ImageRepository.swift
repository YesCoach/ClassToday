//
//  ImageRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import UIKit

protocol ImageRepository {
    // MARK: - POST
    func upload(image: UIImage, completion: @escaping (Result<String, Error>) -> ())

    // MARK: - GET
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> ())

    // MARK: - DELETE
    func deleteImage(urlString: String, completion: @escaping() -> ())
}
