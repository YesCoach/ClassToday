//
//  MapViewController.swift
//  ClassToday
//
//  Created by 박태현 on 2022/06/26.
//

import UIKit
import NMapsMap
import SwiftUI
//import XCTest

class MapViewController: UIViewController {
    //MARK: - NavigationBar Components
    private lazy var leftTitle: UILabel = {
        let leftTitle = UILabel()
        leftTitle.textColor = .black
        leftTitle.sizeToFit()
        leftTitle.text = "우리동네 클래스 스팟"
        leftTitle.font = .systemFont(ofSize: 20.0, weight: .bold)
        return leftTitle
    }()
    
    private lazy var starItem: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.setImage(Icon.star.image, for: .normal)
        button.setImage(Icon.fillStar.image, for: .selected)
        button.addTarget(self, action: #selector(didTapStarButton(_:)), for: .touchUpInside)
        let starItem = UIBarButtonItem(customView: button)
        return starItem
    }()
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftTitle)
        navigationItem.rightBarButtonItems = [starItem]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    //MARK: - Views
    private lazy var categoryView: MapCategoryView = {
        let categoryView = MapCategoryView(frame: .zero)
        categoryView.categoryCollectionView.dataSource = self
        categoryView.categoryCollectionView.delegate = self
        categoryView.delegate = self
        return categoryView
    }()
    
    private lazy var mapView: MapView = {
        let mapView = MapView()
        return mapView
    }()

    private lazy var mapClassListView: MapClassListView = {
        let mapClassListView = MapClassListView()
        mapClassListView.delegate = self
        return mapClassListView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()

    //MARK: - Properties
    private let viewModel = MapViewModel()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        bindViewModel()
        viewModel.checkLocationAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Methods
    private func setupLayout() {
        view.addSubview(categoryView)
        view.addSubview(scrollView)
        categoryView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        scrollView.addSubview(mapView)
        scrollView.addSubview(mapClassListView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(categoryView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalToSuperview()
            $0.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
        mapClassListView.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom)
            $0.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.bottom.equalTo(scrollView.contentLayoutGuide).inset(50)
            $0.width.equalToSuperview()
        }
    }

    private func bindViewModel() {
        /// 위치 정보 권한이 없으면 얼럿 호출
        viewModel.isLocationAuthorizationAllowed.bind { [weak self] isAllowed in
            if !isAllowed {
                self?.present(UIAlertController.locationAlert(), animated: true) {
                    self?.viewModel.checkLocationAuthorization()
                }
            }
        }
        viewModel.currentLocation.bind { [weak self] location in
            guard let location = location else { return }
            self?.setupMapView(location: location)
        }
        viewModel.currentKeyword.bind { [weak self] keyword in
            if let _ = keyword {
                self?.viewModel.fetchKeywordData()
            }
        }
        viewModel.mapClassItemData.bind { [weak self] data in
            self?.mapView.removeMarkers()
            self?.configureMapView(data: data)
        }
        viewModel.listClassItemData.bind { [weak self] data in
            self?.mapClassListView.configure(with: data)
        }
        viewModel.categoryData.bind { [weak self] data in
            self?.categoryView.setPlaceHolderLabel(data.isEmpty)
            if data.isEmpty {
                self?.viewModel.fetchData()
            } else {
                self?.viewModel.fetchCategoryData()
            }
        }
    }

    /// 지도 위치 설정
    private func setupMapView(location: Location) {
        mapView.setUpLocation(location: location)
    }

    /// 지도에 수업 아이템 마커 반영
    private func configureMapView(data: [ClassItem]) {
        mapView.removeMarkers()
        data.forEach {
            mapView.configureClassItemMarker(classItem: $0) {
                self.navigationController?.pushViewController(ClassDetailViewController(classItem: $0), animated: true)
            }
        }
    }
}

//MARK: - objc function
extension MapViewController {
    /// 즐겨찾기 버튼
    @objc private func didTapStarButton(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            viewModel.fetchData()
        } else {
            sender.isSelected = true
            viewModel.fetchStarData()
        }
    }
}

// MARK: - CollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categoryData.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailContentCategoryCollectionViewCell.identifier,
            for: indexPath) as? DetailContentCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureWith(category: viewModel.categoryData.value[indexPath.item])
        return cell
    }
}

// MARK: - CollectionViewDelegateFlowLayout

extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fontsize = viewModel.categoryData.value[indexPath.item].description.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        let width = fontsize.width
        let height = fontsize.height
        return CGSize(width: width + 24, height: height)
    }
}

extension MapViewController: MapCategoryViewDelegate {
    func pushCategorySelectViewController() {
        let viewController = MapCategorySelectViewController(categoryType: .subject)
        viewController.delegate = self
        let selectedCategory = viewModel.categoryData.value
        viewController.configure(with: selectedCategory)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - 카테고리 선택 시 호출
extension MapViewController: MapCategorySelectViewControllerDelegate {
    func passData(categoryItems: [CategoryItem]) {
        viewModel.selectCategory(categories: categoryItems)
    }
}

extension MapViewController: MapClassListViewDelegate {
    func presentViewController(with classItem: ClassItem) {
        navigationController?.pushViewController(ClassDetailViewController(classItem: classItem), animated: true)
    }
}
