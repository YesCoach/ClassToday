//
//  SearchResultViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/17.
//

import Foundation
import RxSwift
import RxCocoa

protocol SearchResultViewModelInput {
    func refreshClassItemList()
    func fetchData()
    func didSelectItem(at index: Int)
    func didSelectSegmentControl(segmentControlIndex: Int)
}

protocol SearchResultViewModelOutput {
    var isNowLocationFetching: BehaviorRelay<Bool> { get }
    var isNowDataFetching: BehaviorRelay<Bool> { get }
    
    var currentUser: BehaviorSubject<User?> { get }
    var outPutData: BehaviorSubject<[ClassItem]> { get }
    
    var classDetailViewController: BehaviorSubject<ClassDetailViewController?> { get }
    var searchKeyword: String { get }
}

protocol SearchResultViewModel: SearchResultViewModelInput, SearchResultViewModelOutput { }

public class DefaultSearchResultViewModel: SearchResultViewModel {
    
    private let fetchClassItemUseCase: FetchClassItemUseCase
    private let disposeBag = DisposeBag()
    
    // MARK: - OUTPUT
    let isNowLocationFetching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isNowDataFetching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    let currentUser: BehaviorSubject<User?> = BehaviorSubject(value: nil)
    let outPutData: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    
    let classDetailViewController: BehaviorSubject<ClassDetailViewController?> = BehaviorSubject(value: nil)
    let searchKeyword: String
    
    private let viewModelData: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    private var currentSegmentControlIndex: Int = 0
    
    // MARK: - Init
    init(fetchClassItemUseCase: FetchClassItemUseCase, searchKeyword: String) {
        self.fetchClassItemUseCase = fetchClassItemUseCase
        self.searchKeyword = searchKeyword
        configureLocation()
    }
    
    /// 유저의 키워드 주소에 따른 기준 지역 구성
    private func configureLocation() {
        isNowLocationFetching.accept(true)
        _ = User.getCurrentUserRx()
            .subscribe(
                onNext: { user in
                    self.currentUser.onNext(user)
                    self.isNowLocationFetching.accept(false)
                    guard let _ = user.detailLocation else {
                        // TODO: 위치 설정 얼럿 호출 해야됨
                        return
                    }
                    self.fetchData()
                },
                onError: { error in
                    self.isNowLocationFetching.accept(false)
                    print("ERROR \(error)🌔")
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - INPUT
extension DefaultSearchResultViewModel {
    func refreshClassItemList() {
        fetchData()
    }
    
    /// cell select 시 호출하는 item 반환 메서드
    func didSelectItem(at index: Int) {
        if let classItem = try? outPutData.value()[index] {
            classDetailViewController.onNext(
                AppDIContainer()
                    .makeDIContainer()
                    .makeClassDetailViewController(classItem: classItem)
            )
            classDetailViewController.onNext(nil)
        }
    }
    
    /// 검색어를 기준으로 수업 아이템을 패칭합니다.
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
        fetchClassItemUseCase.executeRx(
            param: .fetchByKeywordSearch(
                keyword: keyword,
                searchKeyword: searchKeyword
            )
        )
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
