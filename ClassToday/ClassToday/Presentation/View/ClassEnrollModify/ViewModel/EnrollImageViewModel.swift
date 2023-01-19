//
//  EnrollImageViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/03.
//

import UIKit
import PhotosUI

protocol EnrollImageViewModelInput {
    func configureWith(imagesURL: [String]?)
    func removeImages(index: Int)
    func didSelectItem(at index: Int)
}

protocol EnrollImageViewModelOutput {
    var imagesURL: CustomObservable<[String]> { get }
    var images: CustomObservable<[UIImage]> { get }
    var availableImageCount: Int { get }
    var alertController: CustomObservable<UIAlertController?> { get }
    var viewController: CustomObservable<UIViewController?> { get }
}

protocol EnrollImageViewModel: EnrollImageViewModelInput, EnrollImageViewModelOutput { }

final class DefaultEnrollImageViewModel: EnrollImageViewModel {

    private let imageUseCase: ImageUseCase
    private let limitImageCount: Int

    // MARK: - OUTPUT
    let imagesURL: CustomObservable<[String]> = CustomObservable([])
    let images: CustomObservable<[UIImage]> = CustomObservable([])
    var availableImageCount: Int {
        return limitImageCount - images.value.count
    }

    let alertController: CustomObservable<UIAlertController?> = CustomObservable(nil)
    let viewController: CustomObservable<UIViewController?> = CustomObservable(nil)

    // MARK: - Init
    init(imageUseCase: ImageUseCase, limitImageCount: Int = 8) {
        self.imageUseCase = imageUseCase
        self.limitImageCount = limitImageCount
    }

    /// Image를 추가합니다.
    private func appendImages(image: UIImage) {
        images.value.append(image)
    }
}

// MARK: - INPUT
extension DefaultEnrollImageViewModel {
    /// ImagesURL을 가지는 이미지 배열로 초기화합니다.
    func configureWith(imagesURL: [String]?) {
        guard let imagesURL = imagesURL else { return }
        self.imagesURL.value = imagesURL
        let group = DispatchGroup()
        var images: [UIImage] = []
        for url in imagesURL {
            group.enter()
            imageUseCase.downloadImage(urlString: url) { result in
                switch result {
                case .success(let image):
                    images.append(image)
                case .failure(let error):
                    debugPrint(error)
                }
                group.leave()
            }
        }
        group.notify(queue: .global()) { [weak self] in
            self?.images.value = images
        }
    }

    /// Image를 삭제합니다.
    func removeImages(index: Int) {
        if imagesURL.value.isEmpty == false {
            imagesURL.value.remove(at: index)
        }
        images.value.remove(at: index)
    }

    /// ImageCell 선택시 호출합니다.
    func didSelectItem(at index: Int) {
        guard index == 0 else {
            let selectedIndex = index - 1
            viewController.value = FullImagesViewController(images: images.value, startIndex: selectedIndex)
            return
        }
        guard availableImageCount != 0 else {
            let alert = UIAlertController(title: "이미지 등록", message: "이미지 등록은 최대 8개 까지 가능합니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            alertController.value = alert
            return
        }
        let picker = PHPickerViewController.makeImagePicker(selectLimit: availableImageCount)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        viewController.value = picker
    }
}

// MARK: - PHPickerViewControllerDelegate
extension DefaultEnrollImageViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, _) in
                    guard let self = self, let image = image as? UIImage else { return }
                    self.appendImages(image: image)
                }
            }
        }
    }
}
