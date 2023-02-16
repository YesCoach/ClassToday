//
//  MapViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/26.
//

import Foundation
import RxSwift
import RxCocoa

protocol MapViewModelInput {
    func fetchData()
    func fetchCategoryData()
    func fetchStarData()
    func selectCategory(categories: [CategoryItem])
    func viewDidLoad()
    func reloadView()
}

protocol MapViewModelOutput {
    var isLocationAuthorizationAllowed: BehaviorRelay<Bool> { get }
    var currentKeyword: BehaviorSubject<String?> { get }
    var currentLocation: BehaviorSubject<Location?> { get }
    var categoryData: BehaviorSubject<[CategoryItem]> { get }
    var mapClassItemData: BehaviorSubject<[ClassItem]> { get }
    var listClassItemData: BehaviorSubject<[ClassItem]> { get }
    var mapCategorySelectViewController: MapCategorySelectViewController { get }
}

protocol MapViewModel: MapViewModelInput, MapViewModelOutput { }

final class DefaultMapViewModel: MapViewModel {

    // Dependency Injection
    private let userUseCase: UserUseCase
    private let locationUseCase: LocationUseCase
    private let fetchClassItemUseCase: FetchClassItemUseCase
    private let disposeBag = DisposeBag()

    private let userDefaultsManager = UserDefaultsManager.shared
    private let locationManager = LocationManager.shared
    private let firestoreManager = FirestoreManager.shared
    private let naverMapAPIProvider = NaverMapAPIProvider()
    
    private var currentUser: User?
    let isLocationAuthorizationAllowed: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let currentKeyword: BehaviorSubject<String?> = BehaviorSubject(value: nil)
    let currentLocation: BehaviorSubject<Location?> = BehaviorSubject(value: nil)
    let categoryData: BehaviorSubject<[CategoryItem]> = BehaviorSubject(value: [])
    let mapClassItemData: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    let listClassItemData: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    let mapCategorySelectViewController: MapCategorySelectViewController = AppDIContainer()
        .makeDIContainer()
        .makeMapCategorySelectViewController()

    init(
        userUseCase: UserUseCase,
        locationUseCase: LocationUseCase,
        fetchClassItemUseCase: FetchClassItemUseCase
    ) {
        self.userUseCase = userUseCase
        self.locationUseCase = locationUseCase
        self.fetchClassItemUseCase = fetchClassItemUseCase

        bindCategorySelect()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUserData(_:)),
            name: NSNotification.Name("updateUserData"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func getUserData() {
        guard let user = userUseCase.getUserData() else {
            fatalError()
        }
        currentUser = user
    }

    /// 위치정보권한 확인 및 허용 시 지역 패칭
    private func checkLocationAuthorization() {
        isLocationAuthorizationAllowed.accept(locationUseCase.isLocationAuthorizationAllowed())
        if isLocationAuthorizationAllowed.value {
            getCurrentLocation()
        }
    }

    /// 현재 기기 위치를 받아서 지역 키워드를 저장합니다.
    ///
    // TODO: 앱 실행 직후에 기기 위치 정보를 받아올 수 없음. -> Bind로 해결
    private func getCurrentLocation() {
        guard let currentLocationValue = locationUseCase.getCurrentLocation() else { return }
        currentLocation.onNext(currentLocationValue)
        DispatchQueue.global().async { [weak self] in
            self?.naverMapAPIProvider.locationToKeyword(location: currentLocationValue) { result in
                switch result {
                case .success(let keyword):
                    self?.currentKeyword.onNext(keyword)
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }

    /// 전체 수업 아이템 중 키워드 지역에 해당하는 수업 아이템을 분류합니다.
    private func fetchKeywordData(data: [ClassItem]) {
        currentKeyword
            .subscribe(onNext: { [weak self] keyword in
                self?.listClassItemData.onNext(
                    data.filter { $0.keywordLocation == keyword }
                        .sorted { $0 > $1 }
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCategorySelect() {
        categoryData
            .subscribe(onNext: { [weak self] data in
                self?.mapCategorySelectViewController.configure(with: data)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Input

extension DefaultMapViewModel {
    /// 전체 수업 아이템을 패칭합니다.
    func fetchData() {
        fetchClassItemUseCase.executeRx(param: .fetchItems)
            .subscribe(onNext: { [weak self] data in
                self?.mapClassItemData.onNext(data)
                self?.fetchKeywordData(data: data)
            })
            .disposed(by: disposeBag)
    }

    /// 카테고리 수업 리스트를 패칭합니다.
    ///
    /// - 기존 맵 수업 리스트를 카테고리 리스트로 대체
    func fetchCategoryData() {
        guard let categoryDataValue = try? categoryData.value() else { return }
        fetchClassItemUseCase
            .executeRx(param:
                .fetchByCategories(categories: categoryDataValue
                    .map { $0 as? Subject }
                    .compactMap { $0 }
                    .map { $0.rawValue }
                )
            )
            .subscribe(onNext: { [weak self] data in
                self?.mapClassItemData.onNext(data)
            })
            .disposed(by: disposeBag)
    }

    /// 즐겨찾기 수업 리스트를 패칭합니다.
    ///
    /// - 기존 맵 수업 리스트를 즐겨찾기 리스트로 대체
    func fetchStarData() {
        guard let list = currentUser?.stars, list.isEmpty == false else {
            mapClassItemData.onNext([])
            return
        }
        fetchClassItemUseCase.executeRx(param: .fetchByStarlist(starlist: list))
            .subscribe(onNext: { [weak self] data in
                self?.mapClassItemData.onNext(data)
            })
            .disposed(by: disposeBag)
    }

    /// 유저 정보에 변경이 있으면, 새로 업데이트 진행
    @objc func updateUserData(_ notification: Notification) {
        getUserData()
    }

    /// 카테고리 선택시, 선택한 카테고리를 뷰 모델에 반영
    func selectCategory(categories: [CategoryItem]) {
        categoryData.onNext(categories)
    }
    
    func viewDidLoad() {
        checkLocationAuthorization()
        getUserData()
    }
    
    func reloadView() {
        checkLocationAuthorization()
    }
}
