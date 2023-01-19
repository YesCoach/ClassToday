//
//  SearchResultViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/17.
//

import Foundation

protocol SearchResultViewModelInput {
    func refreshClassItemList()
    func didSelectItem(segmentControlIndex: Int, at index: Int)
}

protocol SearchResultViewModelOutput {
    var isLocationAuthorizationAllowed: CustomObservable<Bool> { get }
    var isNowLocationFetching: CustomObservable<Bool> { get }
    var isNowDataFetching: CustomObservable<Bool> { get }
    
    var data: CustomObservable<[ClassItem]> { get }
    var dataBuy: CustomObservable<[ClassItem]> { get }
    var dataSell: CustomObservable<[ClassItem]> { get }
    var selectedClassDetailViewController: CustomObservable<ClassDetailViewController?> { get }
    var searchKeyword: String { get }
}

protocol SearchResultViewModel: SearchResultViewModelInput, SearchResultViewModelOutput { }

public class DefaultSearchResultViewModel: SearchResultViewModel {

    private let fetchClassItemUseCase: FetchClassItemUseCase
    private var currentUser: User?

    // MARK: - OUTPUT
    let isLocationAuthorizationAllowed: CustomObservable<Bool> = CustomObservable(true)
    let isNowLocationFetching: CustomObservable<Bool> = CustomObservable(false)
    let isNowDataFetching: CustomObservable<Bool> = CustomObservable(false)

    let data: CustomObservable<[ClassItem]> = CustomObservable([])
    let dataBuy: CustomObservable<[ClassItem]> = CustomObservable([])
    let dataSell: CustomObservable<[ClassItem]> = CustomObservable([])
    let selectedClassDetailViewController: CustomObservable<ClassDetailViewController?> = CustomObservable(nil)
    let searchKeyword: String

    // MARK: - Init
    init(fetchClassItemUseCase: FetchClassItemUseCase, searchKeyword: String) {
        self.fetchClassItemUseCase = fetchClassItemUseCase
        self.searchKeyword = searchKeyword
        configureLocation()
    }

    /// 키워드 주소를 기준으로 수업 아이템을 검색합니다.
    ///
    /// - 패칭 기준: User의 KeywordLocation 값 ("@@구")
    func fetchData() {
        isNowDataFetching.value = true
        guard let currentUser = currentUser else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.value = false
            return
        }
        guard let keyword = currentUser.keywordLocation else {
            debugPrint("유저의 키워드 주소 설정 값이 없습니다. 주소 설정 먼저 해주세요😭")
            isNowDataFetching.value = false
            return
        }
        fetchClassItemUseCase.excute(param:
                .fetchByKeywordSearch(keyword: keyword, searchKeyword: searchKeyword)) { [weak self] data in
                    self?.isNowDataFetching.value = false
                    // 최신순 정렬
                    self?.data.value = data.sorted { $0 > $1 }
                    self?.dataBuy.value = data.filter { $0.itemType == ClassItemType.buy }.sorted { $0 > $1 }
                    self?.dataSell.value = data.filter { $0.itemType == ClassItemType.sell }.sorted { $0 > $1 }
        }
    }

    /// 유저의 키워드 주소에 따른 기준 지역 구성
    private func configureLocation() {
        isNowLocationFetching.value = true
        User.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                self.isNowLocationFetching.value = false
                guard let _ = user.detailLocation else {
                    // TODO: 위치 설정 얼럿 호출 해야됨
                    return
                }
                self.fetchData()

            case .failure(let error):
                self.isNowLocationFetching.value = false
                print("ERROR \(error)🌔")
            }
        }
    }
}

// MARK: - INPUT
extension DefaultSearchResultViewModel {
    func refreshClassItemList() {
        fetchData()
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
        selectedClassDetailViewController.value = ClassDetailViewController(classItem: classItem)
    }
}
