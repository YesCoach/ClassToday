//
//  EnrollImageCell.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/03.
//

import UIKit
import PhotosUI
import RxSwift

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

    private var viewModel: EnrollImageViewModel = AppDIContainer()
        .makeDIContainer()
        .makeEnrollImageViewModel(limitImageCount: 8)
    private let disposeBag = DisposeBag()

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
        viewModel.configureWith(imagesURL: imagesURL)
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
        .disposed(by: disposeBag)

        viewModel.imagesURL.bind { [weak self] data in
            self?.delegate?.passData(imagesURL: data)
        }
        .disposed(by: disposeBag)

        viewModel.alertController.bind { [weak self] alert in
            self?.delegate?.presentFromImageCell(alert)
        }
        .disposed(by: disposeBag)

        viewModel.viewController.bind { [weak self] viewController in
            self?.delegate?.presentFromImageCell(viewController)
        }
        .disposed(by: disposeBag)
    }
}

// MARK: - CollectionViewDataSource

extension EnrollImageCell: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let count = try? viewModel.images.value().count else {
            return 1
        }
        return count + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let classImageEnrollCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ClassImageEnrollCell.identifier,
                for: indexPath
            ) as? ClassImageEnrollCell
            else {
                return UICollectionViewCell()
            }

            let count = try? viewModel.images.value().count
            classImageEnrollCell.configureWith(count: count ?? 0)

            return classImageEnrollCell
        }

        guard let classImageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ClassImageCell.identifier,
            for: indexPath
        ) as? ClassImageCell,
              let image = try? viewModel.images.value()[indexPath.row - 1]
        else {
            return UICollectionViewCell()
        }

        print(image)
        print(indexPath)
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
        viewModel.didSelectItem(at: indexPath.row)
    }
}

// MARK: - ClassImageCellDelegate

extension EnrollImageCell: ClassImageCellDelegate {
    func deleteImageCell(indexPath: IndexPath) {
        viewModel.removeImages(index: indexPath.row - 1)
    }
}
