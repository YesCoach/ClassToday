//
//  EnrollCategoryCell.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/03.
//

import UIKit
import RxSwift

protocol EnrollCategoryCellDelegate: AnyObject {
    func passData(categoryType: CategoryType, categoryItems: [CategoryItem])
}

class EnrollCategoryCell: UITableViewCell {

    // MARK: - Views
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: contentView.frame.width * 0.50, height: ClassCategoryCollectionViewCell.height)
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ClassCategoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: ClassCategoryCollectionViewCell.identifier)
        collectionView.register(ClassCategoryCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ClassCategoryCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()

    // MARK: - Properties
    weak var delegate: EnrollCategoryCellDelegate?
    static let identifier = "EnrollCategoryCell"
    private var viewModel: EnrollCategoryViewModel = DefaultEnrollCategoryViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureUI()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Method
    private func configureUI() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.categoryType
            .asDriver()
            .drive { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .disposed(by: disposeBag)

        viewModel.selectedCategory
            .asDriver()
            .drive { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - categoryTypeMethod
    func configure(with categoryType: CategoryType, selectedCategory: [CategoryItem]?) {
        viewModel.setCategoryType(with: categoryType)
        viewModel.setSelectedCategory(with: selectedCategory)
    }
}

// MARK: - UICollectionViewDataSource
extension EnrollCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categoryType.value?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:ClassCategoryCollectionViewCell.identifier,
            for: indexPath) as? ClassCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let categoryItem = viewModel.getCategoryItem(at: indexPath.row) else {
            return UICollectionViewCell()
        }
        cell.configure(with: categoryItem,
                       isSelected: viewModel.isCategorySelected(categoryItem: categoryItem))
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ClassCategoryCollectionReusableView.identifier, for: indexPath) as? ClassCategoryCollectionReusableView else {
                return UICollectionReusableView()
            }
            headerView.configure(with: viewModel.categoryType.value ?? .subject)
            return headerView
        default:
            assert(false)
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EnrollCategoryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = CGFloat(ClassCategoryCollectionReusableView.height)
        return CGSize(width: width, height: height)
    }
}

// MARK: - CategoryCollectionViewCellDelegate
extension EnrollCategoryCell: ClassCategoryCollectionViewCellDelegate {
    func reflectSelection(item: CategoryItem?, isChecked: Bool) {
        guard let item = item,
              let type = viewModel.categoryType.value else { return }
        isChecked ? viewModel.appendCategoryItem(with: item) : viewModel.removeCategoryItem(with: item)
        delegate?.passData(categoryType: type,
                           categoryItems: viewModel.selectedCategory.value)
    }
}
