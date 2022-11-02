//
//  EnrollImageViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/03.
//

import UIKit

public class EnrollImageViewModel: ViewModel {

    private let storageManager = StorageManager.shared
    private let limitImageCount: Int

    let imagesURL: Observable<[String]> = Observable([])
    let images: Observable<[UIImage]> = Observable([])
    var availableImageCount: Int {
        return limitImageCount - images.value.count
    }
    init(limitImageCount: Int = 8) {
        self.limitImageCount = limitImageCount
    }
    
    /// ImagesURL 배열과 Image 배열을 설정합니다.
    func setImages(imagesURL: [String]?) {
        guard let imagesURL = imagesURL else { return }
        self.imagesURL.value = imagesURL
        let group = DispatchGroup()
        var images: [UIImage] = []
        for url in imagesURL {
            group.enter()
            storageManager.downloadImage(urlString: url) { result in
                switch result {
                case .success(let image):
                    images.append(image)
                case .failure(let error):
                    debugPrint(error)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) { [weak self] in
            self?.images.value = images
        }
    }
    
    /// Image를 추가합니다.
    func appendImages(image: UIImage) {
        images.value.append(image)
    }

    /// Image를 삭제합니다.
    func removeImages(index: Int) {
        if imagesURL.value.isEmpty == false {
            imagesURL.value.remove(at: index)
        }
        images.value.remove(at: index)
    }
}
