//
//  MapCategorySelectViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/31.
//

import Foundation
import RxSwift

protocol MapCategorySelectViewModelInput {
    func updateData(data: [CategoryItem])
    func insertData(data: CategoryItem)
    func removeData(data: CategoryItem)
}

protocol MapCategorySelectViewModelOutput {
    var selectedCategory: BehaviorSubject<[CategoryItem]> { get }
    var categoryType: CategoryType { get }

    /// 특정 카테고리 항목을 받아옵니다.
    func getCategoryItem(at index: Int) -> CategoryItem
    /// 포함되어 있는지 확인 후 Boolean 반환
    func isCategorySelected(categoryItem: CategoryItem) -> Bool
}

protocol MapCategorySelectViewModel: MapCategorySelectViewModelInput,
                                     MapCategorySelectViewModelOutput { }

final class DefaultMapCategorySelectViewModel: MapCategorySelectViewModel {
    let selectedCategory: BehaviorSubject<[CategoryItem]> = BehaviorSubject(value: [])
    let categoryType: CategoryType

    init(categoryType: CategoryType = .subject) {
        self.categoryType = categoryType
    }

    /// 특정 카테고리 항목을 받아옵니다.
    func getCategoryItem(at index: Int) -> CategoryItem {
        return categoryType.allcases[index]
    }

    /// 포함되어 있는지 확인 후 Boolean 반환
    func isCategorySelected(categoryItem: CategoryItem) -> Bool {
        guard let selectedCategoryValue = try? selectedCategory.value() else {
            return false
        }
        return selectedCategoryValue.contains { item in
            item.description == categoryItem.description
        }
    }
}

// MARK: - Input

extension DefaultMapCategorySelectViewModel {

    func updateData(data: [CategoryItem]) {
        selectedCategory.onNext(data)
    }

    func insertData(data: CategoryItem) {
        if var selectedCategoryValue = try? selectedCategory.value() {
            selectedCategoryValue.append(data)
            selectedCategory.onNext(selectedCategoryValue)
        }
    }

    func removeData(data: CategoryItem) {
        guard var selectedCategoryValue = try? selectedCategory.value(),
              let index = selectedCategoryValue.firstIndex(
                where: { $0.description == data.description }
              )
        else { return }
        selectedCategoryValue.remove(at: index)
        selectedCategory.onNext(selectedCategoryValue)
    }
}
