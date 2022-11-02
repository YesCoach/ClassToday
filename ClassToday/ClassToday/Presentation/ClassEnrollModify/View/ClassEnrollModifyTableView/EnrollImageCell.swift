//
//  EnrollImageCell.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/03.
//

import UIKit
import PhotosUI

protocol EnrollImageCellDelegate: AnyObject {
    func presentFromImageCell(_ viewController: UIViewController)
    func passData(images: [UIImage])
    func passData(imagesURL: [String])
}

class EnrollImageCell: UITableViewCell {

    // MARK: - Views

    private lazy var imageEnrollCollectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumInteritemSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ClassImageCell.self, forCellWithReuseIdentifier: ClassImageCell.identifier)
        collectionView.register(ClassImageEnrollCell.self, forCellWithReuseIdentifier: ClassImageEnrollCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    // MARK: - Properties
    static var identifier = "EnrollImageCell"
    weak var delegate: EnrollImageCellDelegate?
    private var viewModel: EnrollImageViewModel = EnrollImageViewModel(limitImageCount: 8)

    // MARK: - Initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureUI()
        bindingViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Method
    func configureWith(imagesURL: [String]?) {
        viewModel.setImages(imagesURL: imagesURL)
    }

    private func configureUI() {
        contentView.addSubview(imageEnrollCollectionView)
        imageEnrollCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bindingViewModel() {
        viewModel.images.bind { [weak self] data in
            self?.delegate?.passData(images: data)
            DispatchQueue.main.async {
                self?.imageEnrollCollectionView.reloadData()
            }
        }
        viewModel.imagesURL.bind { [weak self] data in
            self?.delegate?.passData(imagesURL: data)
        }
    }
}

// MARK: - CollectionViewDataSource
extension EnrollImageCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.value.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let classImageEnrollCell = collectionView.dequeueReusableCell(withReuseIdentifier: ClassImageEnrollCell.identifier, for: indexPath) as? ClassImageEnrollCell else {
                return UICollectionViewCell()
            }
            classImageEnrollCell.configureWith(count: viewModel.images.value.count)
            return classImageEnrollCell
        }
        guard let classImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ClassImageCell.identifier, for: indexPath) as? ClassImageCell else {
            return UICollectionViewCell()
        }
        let image = viewModel.images.value[indexPath.row-1]
        classImageCell.configureWith(image: image, indexPath: indexPath)
        classImageCell.delegate = self
        return classImageCell
    }
}

// MARK: - CollectionViewDeleagetFlowLayout

extension EnrollImageCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 3.5
        return CGSize(width: width / itemsPerRow, height: height * 0.7)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - CollectionViewDelegate

extension EnrollImageCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let availableImageCount = viewModel.availableImageCount
        if indexPath.row == 0 {
            if availableImageCount == 0 {
                let alert = UIAlertController(title: "이미지 등록", message: "이미지 등록은 최대 8개 까지 가능합니다", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                alert.addAction(action)
                delegate?.presentFromImageCell(alert)
                return
            }
            let picker = PHPickerViewController.makeImagePicker(selectLimit: availableImageCount)
            picker.delegate = self
            picker.modalPresentationStyle = .fullScreen
            delegate?.presentFromImageCell(picker)
        } else {
            let selectedIndex = indexPath.row - 1
            let fullImageViewController = FullImagesViewController(images: viewModel.images.value, startIndex: selectedIndex)
            delegate?.presentFromImageCell(fullImageViewController)
        }
    }
}

// MARK: - ClassImageCellDelegate
extension EnrollImageCell: ClassImageCellDelegate {
    func deleteImageCell(indexPath: IndexPath) {
        viewModel.removeImages(index: indexPath.row - 1)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension EnrollImageCell: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, _) in
                    guard let self = self, let image = image as? UIImage else { return }
                    self.viewModel.appendImages(image: image)
                }
            }
        }
    }
}
