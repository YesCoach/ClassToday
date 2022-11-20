//
//  MainViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/13.
//

import Foundation

enum LocationError: Error {
    case NonSavedLocation
}

protocol MainViewModelInput {
    func refreshClassItemList()
    func viewWillAppear()
    func fetchData()
    func checkLocationAuthorization()
    func didTapCategoryButton()
    func didTapStarButton()
    func didSelectItem(segmentControlIndex: Int, at index: Int)
}

protocol MainViewModelOutput {
    var isNowLocationFetching: Observable<Bool> { get }
    var isNowDataFetching: Observable<Bool> { get }
    var isLocationAuthorizationAllowed: Observable<Bool> { get }
    var locationTitle: Observable<String?> { get }

    var currentUser: Observable<User?> { get }
    var data: Observable<[ClassItem]> { get }
    var dataBuy: Observable<[ClassItem]> { get }
    var dataSell: Observable<[ClassItem]> { get }
    
    var classDetailViewController: Observable<ClassDetailViewController?> { get }
    var categoryListViewController: Observable<CategoryListViewController?> { get }
    var starViewController: Observable<StarViewController?> { get }
}

protocol MainViewModel: MainViewModelInput, MainViewModelOutput {}

final class DefaultMainViewModel: MainViewModel {

    private let fetchClassItemUseCase: FetchClassItemUseCase
    private let locationManager = LocationManager.shared

    // MARK: - OUTPUT
    let isNowLocationFetching: Observable<Bool> = Observable(false)
    let isNowDataFetching: Observable<Bool> = Observable(false)
    let isLocationAuthorizationAllowed: Observable<Bool> = Observable(true)
    let locationTitle: Observable<String?> = Observable(nil)

    let currentUser: Observable<User?> = Observable(nil)
    let data: Observable<[ClassItem]> = Observable([])
    let dataBuy: Observable<[ClassItem]> = Observable([])
    let dataSell: Observable<[ClassItem]> = Observable([])

    let classDetailViewController: Observable<ClassDetailViewController?> = Observable(nil)
    let categoryListViewController: Observable<CategoryListViewController?> = Observable(nil)
    let starViewController: Observable<StarViewController?> = Observable(nil)

    // MARK: - Init
    init(fetchClassItemUseCase: FetchClassItemUseCase) {
        self.fetchClassItemUseCase = fetchClassItemUseCase
        checkLocationAuthorization()
        configureLocation()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUserData(_:)),
                                               name: NSNotification.Name("updateUserData"),
                                               object: nil)
    }

    /// 유저의 키워드 주소에 따른 기준 지역 구성
    ///
    ///  - 출력 형태: "@@시 @@구의 수업"
    private func configureLocation() {
        isNowLocationFetching.value = true
        User.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser.value = user
                self.isNowLocationFetching.value = false
                guard let location = user.detailLocation else {
                    // TODO: 위치 설정 얼럿 호출 해야됨
                    self.locationTitle.value = nil
                    return
                }
                self.locationTitle.value = "\(location)의 수업"

            case .failure(let error):
                self.isNowLocationFetching.value = false
                self.locationTitle.value = nil
                print("ERROR \(error)🌔")
            }
        }
    }

    /// 유저 정보에 변경이 있으면, 새로 업데이트 진행
    @objc func updateUserData(_ notification: Notification) {
        configureLocation()
    }
}

// MARK: - INPUT
extension DefaultMainViewModel {
    func refreshClassItemList() {
        checkLocationAuthorization()
        fetchData()
    }

    func viewWillAppear() {
        checkLocationAuthorization()
    }

    /// 키워드 주소를 기준으로 수업 아이템을 패칭합니다.
    ///
    /// - 패칭 기준: User의 KeywordLocation 값 ("@@구")
    func fetchData() {
        isNowDataFetching.value = true
        guard let currentUser = self.currentUser.value else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.value = false
            return
        }
        guard let keyword = currentUser.keywordLocation else {
            debugPrint("유저의 키워드 주소 설정 값이 없습니다. 주소 설정 먼저 해주세요😭")
            isNowDataFetching.value = false
            return
        }
        guard isLocationAuthorizationAllowed.value else {
            debugPrint("위치정보권한이 허용되지 않았습니다. 권한을 허용해주세요😭")
            isNowDataFetching.value = false
            return
        }
        fetchClassItemUseCase.excute(param: .fetchByKeyword(keyword: keyword)) { [weak self] data in
            self?.isNowDataFetching.value = false
            // 최신순 정렬
            self?.data.value = data.sorted { $0 > $1 }
            self?.dataBuy.value = data.filter { $0.itemType == ClassItemType.buy }.sorted { $0 > $1 }
            self?.dataSell.value = data.filter { $0.itemType == ClassItemType.sell }.sorted { $0 > $1 }
        }
    }

    /// 위치정보 권한의 상태값을 체크합니다.
    func checkLocationAuthorization() {
        isLocationAuthorizationAllowed.value = LocationManager.shared.isLocationAuthorizationAllowed()
    }

    func didTapCategoryButton() {
        categoryListViewController.value =  AppDIContainer()
            .makeDIContainer()
            .makeCategoryListViewController(categoryType: .subject)
    }

    func didTapStarButton() {
        starViewController.value = AppDIContainer().makeDIContainer().makeStarViewController()
    }

    func didSelectItem(segmentControlIndex: Int, at index: Int) {
        let classItem: ClassItem
        switch segmentControlIndex {
            case 1:
            classItem = dataBuy.value[index]
            case 2:
            classItem = dataSell.value[index]
            default:
            classItem = data.value[index]
        }
        classDetailViewController.value = ClassDetailViewController(classItem: classItem)
    }
}
