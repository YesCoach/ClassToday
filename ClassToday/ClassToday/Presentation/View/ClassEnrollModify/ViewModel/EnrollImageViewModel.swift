//
//  EnrollImageViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/03.
//

import UIKit
import PhotosUI
import RxSwift

protocol EnrollImageViewModelInput {
    func configureWith(imagesURL: [String]?)
    func removeImages(index: Int)
    func didSelectItem(at index: Int)
}

protocol EnrollImageViewModelOutput {
    var availableImageCount: Int { get }
    var imagesURL: BehaviorSubject<[String]> { get }
    var images: BehaviorSubject<[UIImage]> { get }
    var alertController: PublishSubject<UIAlertController> { get }
    var viewController: PublishSubject<UIViewController> { get }
}

protocol EnrollImageViewModel: EnrollImageViewModelInput, EnrollImageViewModelOutput { }

final class DefaultEnrollImageViewModel: EnrollImageViewModel {

    private let imageUseCase: ImageUseCase
    private let limitImageCount: Int
    private var isImagesAlreadyInitialized: Bool = false
    private let disposeBag = DisposeBag()

    // MARK: - OUTPUT

    let imagesURL: BehaviorSubject<[String]> = BehaviorSubject(value: [])
    let images: BehaviorSubject<[UIImage]> = BehaviorSubject(value: [])
    let alertController: PublishSubject<UIAlertController> = PublishSubject<UIAlertController>()
    let viewController: PublishSubject<UIViewController> = PublishSubject<UIViewController>()

    var availableImageCount: Int {
        guard let imagesCount = try? images.value().count else { return limitImageCount }
        return limitImageCount - imagesCount
    }

    // MARK: - Init

    init(imageUseCase: ImageUseCase, limitImageCount: Int = 8) {
        self.imageUseCase = imageUseCase
        self.limitImageCount = limitImageCount
    }

    /// Image를 추가합니다.
    private func appendImages(image: UIImage) {
        guard var imagesValue = try? images.value() else {
            images.onNext([image])
            return
        }

        imagesValue.append(image)
        images.onNext(imagesValue)
    }
}

// MARK: - INPUT

extension DefaultEnrollImageViewModel {
    /// ImagesURL을 가지는 이미지 배열로 초기화합니다.
    func configureWith(imagesURL: [String]?) {
        guard isImagesAlreadyInitialized == false,
              let imagesURL = imagesURL
        else { return }

        self.imagesURL.onNext(imagesURL)

        let group = DispatchGroup()
        var images: [UIImage] = []

        for url in imagesURL {
            group.enter()
            imageUseCase.downloadImageRx(urlString: url)
                .subscribe(
                    onNext: { image in
                        images.append(image)
                    },
                    onError: { error in
                        debugPrint(error.localizedDescription)
                    },
                    onDisposed: {
                        group.leave()
                    }
                )
                .disposed(by: disposeBag)
        }

        group.notify(queue: .global()) { [weak self] in
            self?.images.onNext(images)
        }

        isImagesAlreadyInitialized = true
    }

    /// Image를 삭제합니다.
    func removeImages(index: Int) {
        guard var imagesURLValue = try? imagesURL.value(),
              var imagesValue = try? images.value(),
              imagesURLValue.isEmpty == false
        else { return }

        if imagesURLValue.count >= index + 1{
            imagesURLValue.remove(at: index)
        }
        imagesValue.remove(at: index)

        imagesURL.onNext(imagesURLValue)
        images.onNext(imagesValue)
    }

    /// ImageCell 선택시 호출합니다.
    func didSelectItem(at index: Int) {
        guard index == 0 else {
            guard let imagesValue = try? images.value() else { return }
            let selectedIndex = index - 1

            viewController.onNext(
                FullImagesViewController(images: imagesValue, startIndex: selectedIndex)
            )

            return
        }

        guard availableImageCount != 0 else {
            let alert = UIAlertController(
                title: "이미지 등록",
                message: "이미지 등록은 최대 8개 까지 가능합니다",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)

            alertController.onNext(alert)

            return
        }

        let picker = PHPickerViewController.makeImagePicker(selectLimit: availableImageCount)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen

        viewController.onNext(picker)
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
