//
//  EnrollCategoryViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/03.
//

import Foundation
import RxSwift
import RxCocoa

protocol EnrollCategoryViewModelInput {
    func setCategoryType(with categoryType: CategoryType)
    func setSelectedCategory(with selectedCategory: [CategoryItem]?)
    func appendCategoryItem(with categoryItem: CategoryItem)
    func removeCategoryItem(with categoryItem: CategoryItem)
    func getCategoryItem(at index: Int) -> CategoryItem?
    func isCategorySelected(categoryItem: CategoryItem) -> Bool
}

protocol EnrollCategoryViewModelOutput {
    var categoryType: BehaviorRelay<CategoryType?> { get }
    var selectedCategory: BehaviorRelay<[CategoryItem]> { get }
}

protocol EnrollCategoryViewModel: EnrollCategoryViewModelInput, EnrollCategoryViewModelOutput { }

public class DefaultEnrollCategoryViewModel: EnrollCategoryViewModel {
 
    // MARK: - OUTPUT
    
    let categoryType: BehaviorRelay<CategoryType?> = BehaviorRelay(value: nil)
    let selectedCategory: BehaviorRelay<[CategoryItem]> = BehaviorRelay(value: [])
}

// MARK: - INPUT
extension DefaultEnrollCategoryViewModel {

    /// CategoryType을 설정합니다.
    func setCategoryType(with categoryType: CategoryType) {
        self.categoryType.accept(categoryType)
    }

    /// 선택된 Category 항목들을 반영합니다.
    func setSelectedCategory(with selectedCateogry: [CategoryItem]?) {
        guard let selectedCateogry = selectedCateogry else { return }
        self.selectedCategory.accept(selectedCateogry)
    }

    /// Category 항목 체크시 해당 항목을 추가합니다.
    func appendCategoryItem(with categoryItem: CategoryItem) {
        var selectedCategoryValue = selectedCategory.value
        selectedCategoryValue.append(categoryItem)

        selectedCategory.accept(selectedCategoryValue)
    }

    /// Category 항목을 체크해제시 해당 항목을 삭제합니다.
    func removeCategoryItem(with categoryItem: CategoryItem) {
        guard let index = selectedCategory.value.firstIndex(
            where: { $0.description == categoryItem.description }
        )
        else { return }

        var selectedCategoryValue = selectedCategory.value
        selectedCategoryValue.remove(at: index)
        selectedCategory.accept(selectedCategoryValue)
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
