//
//  MainViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/13.
//

import Foundation
import RxSwift
import RxCocoa

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
    func didSelectItem(at index: Int)
    func didSelectSegmentControl(segmentControlIndex: Int)
}

protocol MainViewModelOutput {
    var isNowLocationFetching: BehaviorRelay<Bool> { get }
    var isNowDataFetching: BehaviorRelay<Bool> { get }
    var isLocationAuthorizationAllowed: BehaviorRelay<Bool> { get }
    var locationTitle: BehaviorSubject<String?> { get }

    var currentUser: BehaviorSubject<User?> { get }
    var outPutData: BehaviorSubject<[ClassItem]> { get }

    var classDetailViewController: BehaviorSubject<ClassDetailViewController?> { get }
    var categoryListViewController: BehaviorSubject<CategoryListViewController?> { get }
    var starViewController: BehaviorSubject<StarViewController?> { get }
}

protocol MainViewModel: MainViewModelInput, MainViewModelOutput {}

final class DefaultMainViewModel: MainViewModel {
    
    private let fetchClassItemUseCase: FetchClassItemUseCase
    private let locationManager = LocationManager.shared
    private let disposeBag = DisposeBag()
    
    // MARK: - OUTPUT
    let isNowLocationFetching: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    let isNowDataFetching: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    let isLocationAuthorizationAllowed: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    let locationTitle: BehaviorSubject<String?> = BehaviorSubject<String?>(value: nil)
    
    let currentUser: BehaviorSubject<User?> = BehaviorSubject<User?>(value: nil)
    let outPutData: BehaviorSubject<[ClassItem]> = BehaviorSubject<[ClassItem]>(value: [])

    let classDetailViewController: BehaviorSubject<ClassDetailViewController?> = BehaviorSubject<ClassDetailViewController?>(value: nil)
    let categoryListViewController: BehaviorSubject<CategoryListViewController?> = BehaviorSubject<CategoryListViewController?>(value: nil)
    let starViewController: BehaviorSubject<StarViewController?> = BehaviorSubject<StarViewController?>(value: nil)

    private let viewModelData: BehaviorSubject<[ClassItem]> = BehaviorSubject<[ClassItem]>(value: [])
    private var currentSegmentControlIndex: Int = 0
    
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
        isNowLocationFetching.accept(true)
        _ = User.getCurrentUserRx()
            .subscribe(
                onNext: { user in
                    self.currentUser.onNext(user)
                    self.isNowLocationFetching.accept(false)
                    guard let location = user.detailLocation else {
                        // TODO: 위치 설정 얼럿 호출 해야됨
                        self.locationTitle.onNext(nil)
                        return
                    }
                    self.locationTitle.onNext("\(location)의 수업")
                },
                onError: { error in
                    self.isNowLocationFetching.accept(false)
                    self.locationTitle.onNext(nil)
                    print("ERROR \(error)🌔")
                }
            )
            .disposed(by: disposeBag)
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
        isNowDataFetching.accept(true)
        guard let currentUser = try? currentUser.value() else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.accept(false)
            return
        }
        guard let keyword = currentUser.keywordLocation else {
            debugPrint("유저의 키워드 주소 설정 값이 없습니다. 주소 설정 먼저 해주세요😭")
            isNowDataFetching.accept(false)
            return
        }
        guard isLocationAuthorizationAllowed.value else {
            debugPrint("위치정보권한이 허용되지 않았습니다. 권한을 허용해주세요😭")
            isNowDataFetching.accept(false)
            return
        }
        fetchClassItemUseCase.excuteRx(param: .fetchByKeyword(keyword: keyword))
            .map { (classItems) -> [ClassItem] in
                classItems.sorted { $0 > $1 }
            }
            .subscribe( onNext: { [weak self] classItems in
                self?.isNowDataFetching.accept(false)
                self?.viewModelData.onNext(classItems)
                switch self?.currentSegmentControlIndex {
                case 1:
                    self?.outPutData.onNext(classItems.filter { $0.itemType == ClassItemType.buy })
                case 2:
                    self?.outPutData.onNext(classItems.filter { $0.itemType == ClassItemType.sell })
                default:
                    self?.outPutData.onNext(classItems)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 위치정보 권한의 상태값을 체크합니다.
    func checkLocationAuthorization() {
        isLocationAuthorizationAllowed.accept(locationManager.isLocationAuthorizationAllowed())
    }
    
    func didTapCategoryButton() {
        categoryListViewController.onNext(AppDIContainer()
            .makeDIContainer()
            .makeCategoryListViewController(categoryType: .subject)
        )
    }
    
    func didTapStarButton() {
        starViewController.onNext(AppDIContainer()
            .makeDIContainer()
            .makeStarViewController()
        )
    }

    /// cell select 시 호출하는 item 반환 메서드
    func didSelectItem(at index: Int) {
        if let classItem = try? outPutData.value()[index] {
            classDetailViewController.onNext(
                AppDIContainer()
                    .makeDIContainer()
                    .makeClassDetailViewController(classItem: classItem)
            )
        }
    }

    func didSelectSegmentControl(segmentControlIndex: Int) {
        self.currentSegmentControlIndex = segmentControlIndex

        guard let datas = try? viewModelData.value() else {
            outPutData.onNext([])
            return
        }

        switch segmentControlIndex {
        case 1:
            outPutData.onNext(datas.filter { $0.itemType == .buy })
        case 2:
            outPutData.onNext(datas.filter { $0.itemType == .sell })
        default:
            outPutData.onNext(datas)
        }
    }
}
