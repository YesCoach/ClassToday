//
//  CategoryListViewController.swift
//  ClassToday
//
//  Created by poohyhy on 2022/04/20.
//

import UIKit
import SnapKit

class CategoryListViewController: UIViewController {
    //MARK: - NavigationBar Components
    private lazy var leftBarItem: UIBarButtonItem = {
        let leftBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBackButton))
        return leftBarItem
    }()

    private lazy var navigationTitle: UILabel = {
        let navigationTitle = UILabel()
        navigationTitle.text = "카테고리"
        navigationTitle.textColor = .black
        navigationTitle.font = .systemFont(ofSize: 18.0, weight: .semibold)
        return navigationTitle
    }()

    //MARK: - CollectionView
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        return collectionViewLayout
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.showsVerticalScrollIndicator = false
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(
            CategoryListCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryListCollectionViewCell.identifier
        )
        return categoryCollectionView
    }()

    private var viewModel: CategoryListViewModel

    // MARK: - Init
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        layout()
        bindingViewModel()
    }

    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.titleView = navigationTitle
    }

    private func bindingViewModel() {
        viewModel.categoryDetailViewController.bind { [weak self] viewController in
            if let viewController = viewController {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

//MARK: - objc functions
private extension CategoryListViewController {
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - collectionview delegate flow layout
extension CategoryListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 3

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

//MARK: - collectionview datasource
extension CategoryListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categoryListCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryListCollectionViewCell.identifier,
            for: indexPath
        ) as? CategoryListCollectionViewCell else { return UICollectionViewCell() }
        cell.configureWith(categoryItem: viewModel.categoryList[indexPath.row])
        return cell
    }
}

//MARK: - collectionview delegate
extension CategoryListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAt(index: indexPath.row)
    }
}

//MARK: - set autolayout
private extension CategoryListViewController {
    func layout() {
        [
            categoryCollectionView
        ].forEach { view.addSubview($0) }
        
        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(30.0)
            $0.leading.trailing.bottom.equalToSuperview().inset(10.0)
        }
    }
}
