//
//  ImageUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import UIKit
import RxSwift

protocol ImageUseCase {
    func uploadRx(image: UIImage) -> Observable<String>
    func downloadImageRx(urlString: String) -> Observable<UIImage>
    func deleteImageRx(urlString: String) -> Observable<Void>
}

final class DefaultImageUseCase: ImageUseCase {

    private let imageRepository: ImageRepository

    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    func uploadRx(image: UIImage) -> Observable<String> {
        return Observable.create { [weak self] emitter in
            self?.imageRepository.upload(image: image) { result in
                switch result {
                case .success(let url):
                    emitter.onNext(url)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func downloadImageRx(urlString: String) -> Observable<UIImage> {
        return Observable.create { [weak self] emitter in
            self?.imageRepository.downloadImage(urlString: urlString) { result in
                switch result {
                case .success(let image):
                    emitter.onNext(image)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func deleteImageRx(urlString: String) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            self?.imageRepository.deleteImage(urlString: urlString) {
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
