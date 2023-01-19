//
//  CategoryDetailViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/18.
//

import Foundation

protocol CategoryDetailViewModelInput {
    func refreshClassItemList()
    func didSelectItem(segmentControlIndex: Int, at index: Int)
}

protocol CategoryDetailViewModelOutput {
    var isLocationAuthorizationAllowed: CustomObservable<Bool> { get }
    var isNowLocationFetching: CustomObservable<Bool> { get }
    var isNowDataFetching: CustomObservable<Bool> { get }
    var categoryItem: CategoryItem { get }

    var data: CustomObservable<[ClassItem]> { get }
    var dataBuy: CustomObservable<[ClassItem]> { get }
    var dataSell: CustomObservable<[ClassItem]> { get }
    var selectedClassDetailViewController: CustomObservable<ClassDetailViewController?> { get }
}

protocol CategoryDetailViewModel: CategoryDetailViewModelInput, CategoryDetailViewModelOutput { }

public class DefaultCategoryDetailViewModel: CategoryDetailViewModel {
    private var currentUser: User?

    // MARK: - OUTPUT
    var isLocationAuthorizationAllowed: CustomObservable<Bool> = CustomObservable(true)
    var isNowLocationFetching: CustomObservable<Bool> = CustomObservable(false)
    var isNowDataFetching: CustomObservable<Bool> = CustomObservable(false)

    let data: CustomObservable<[ClassItem]> = CustomObservable([])
    let dataBuy: CustomObservable<[ClassItem]> = CustomObservable([])
    let dataSell: CustomObservable<[ClassItem]> = CustomObservable([])
    let selectedClassDetailViewController: CustomObservable<ClassDetailViewController?> = CustomObservable(nil)

    private let fetchClassItemUseCase: FetchClassItemUseCase
    let categoryItem: CategoryItem

    init(fetchClassItemUseCase: FetchClassItemUseCase, categoryItem: CategoryItem) {
        self.fetchClassItemUseCase = fetchClassItemUseCase
        self.categoryItem = categoryItem
        configureLocation()
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
                .fetchByKeywordCategory(keyword: keyword,
                                        category: categoryItem.rawValue)) { [weak self] data in
            self?.data.value = data
            self?.dataBuy.value = data.filter { $0.itemType == ClassItemType.buy }
            self?.dataSell.value = data.filter { $0.itemType == ClassItemType.sell }
            self?.isNowDataFetching.value = false
        }
    }
}

extension DefaultCategoryDetailViewModel {
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
