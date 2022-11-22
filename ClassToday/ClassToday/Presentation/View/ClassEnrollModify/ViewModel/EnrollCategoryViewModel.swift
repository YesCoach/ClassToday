//
//  EnrollCategoryViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/03.
//

import Foundation

protocol EnrollCategoryViewModelInput {
    func setCategoryType(with categoryType: CategoryType)
    func setSelectedCategory(with selectedCategory: [CategoryItem]?)
    func appendCategoryItem(with categoryItem: CategoryItem)
    func removeCategoryItem(with categoryItem: CategoryItem)
    func getCategoryItem(at index: Int) -> CategoryItem?
    func isCategorySelected(categoryItem: CategoryItem) -> Bool
}

protocol EnrollCategoryViewModelOutput {
    var categoryType: Observable<CategoryType?> { get }
    var selectedCategory: Observable<[CategoryItem]> { get }
}

protocol EnrollCategoryViewModel: EnrollCategoryViewModelInput, EnrollCategoryViewModelOutput { }

public class DefaultEnrollCategoryViewModel: EnrollCategoryViewModel {
    // MARK: - OUTPUT
    let categoryType: Observable<CategoryType?> = Observable(nil)
    let selectedCategory: Observable<[CategoryItem]> = Observable([])
}

// MARK: - INPUT
extension DefaultEnrollCategoryViewModel {

    /// CategoryType을 설정합니다.
    func setCategoryType(with categoryType: CategoryType) {
        self.categoryType.value = categoryType
    }

    /// 선택된 Category 항목들을 반영합니다.
    func setSelectedCategory(with selectedCateogry: [CategoryItem]?) {
        guard let selectedCateogry = selectedCateogry else {
            return
        }
        self.selectedCategory.value = selectedCateogry
    }

    /// Category 항목 체크시 해당 항목을 추가합니다.
    func appendCategoryItem(with categoryItem: CategoryItem) {
        selectedCategory.value.append(categoryItem)
    }

    /// Category 항목을 체크해제시 해당 항목을 삭제합니다.
    func removeCategoryItem(with categoryItem: CategoryItem) {
        guard let index = selectedCategory.value.firstIndex(where: {$0.description == categoryItem.description}) else {
            return
        }
        selectedCategory.value.remove(at: index)
    }

    /// 특정 카테고리 항목을 받아옵니다.
    func getCategoryItem(at index: Int) -> CategoryItem? {
        guard let type = categoryType.value else { return nil }
        return type.allcases[index]
    }

    /// 해당 항목이 선택되어 있는지 확인 후 유무를 반환합니다.
    func isCategorySelected(categoryItem: CategoryItem) -> Bool {
        return selectedCategory.value.contains { item in
            item.description == categoryItem.description
        }
    }
}
