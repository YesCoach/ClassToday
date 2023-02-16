//
//  MapCategorySelectView.swift
//  ClassToday
//
//  Created by 박태현 on 2022/07/03.
//

import UIKit

protocol MapCategorySelectViewControllerDelegate: AnyObject {
    func passData(categoryItems: [CategoryItem])
}

class MapCategorySelectViewController: UIViewController {

    //MARK: - NavigationBar Components

    private lazy var leftBarItem: UIBarButtonItem = {
        let leftBarItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        return leftBarItem
    }()

    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftBarItem
    }

    // MARK: - Views

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(
            width: view.frame.width * 0.40,
            height: ClassCategoryCollectionViewCell.height
        )
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            ClassCategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: ClassCategoryCollectionViewCell.identifier
        )
        collectionView.register(
            ClassCategoryCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ClassCategoryCollectionReusableView.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()

    // MARK: - Properties

    weak var delegate: MapCategorySelectViewControllerDelegate?
    private var viewModel: MapCategorySelectViewModel

    // MARK: - Initialize

    init(viewModel: MapCategorySelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setNavigationBar()
        navigationController?.navigationItem.leftBarButtonItem?.title = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let items = try? viewModel.selectedCategory.value() {
            delegate?.passData(categoryItems: items)
        }
    }

    // MARK: - Method

    private func configureUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }

    // MARK: - categoryTypeMethod

    func configure(with selectedItem: [CategoryItem]?) {
        guard let selectedItem = selectedItem else {
            return
        }
        viewModel.updateData(data: selectedItem)
    }

    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension MapCategorySelectViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.categoryType.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:ClassCategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? ClassCategoryCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        let categoryItem = viewModel.getCategoryItem(at: indexPath.row)
        cell.configure(
            with: categoryItem,
            isSelected: viewModel.isCategorySelected(categoryItem: categoryItem)
        )
        cell.delegate = self
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ClassCategoryCollectionReusableView.identifier,
                for: indexPath
            ) as? ClassCategoryCollectionReusableView
            else {
                return UICollectionReusableView()
            }
            headerView.configure(with: viewModel.categoryType)
            return headerView
        default:
            assert(false)
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MapCategorySelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = CGFloat(ClassCategoryCollectionReusableView.height)
        return CGSize(width: width, height: height)
    }
}

// MARK: - CategoryCollectionViewCellDelegate

extension MapCategorySelectViewController: ClassCategoryCollectionViewCellDelegate {
    func reflectSelection(item: CategoryItem?, isChecked: Bool) {
        guard let item = item else { return }
        if isChecked {
            viewModel.insertData(data: item)
        } else {
            viewModel.removeData(data: item)
        }
    }
}
