//
//  MapCategorySelectViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/31.
//

import Foundation

public class MapCategorySelectViewModel: ViewModel {
    let selectedCategory: Observable<[CategoryItem]> = Observable([])
    let categoryType: CategoryType

    init(categoryType: CategoryType = .subject) {
        self.categoryType = categoryType
    }

    func updateData(data: [CategoryItem]) {
        selectedCategory.value = data
    }
    func insertData(data: CategoryItem) {
        selectedCategory.value.append(data)
    }
    func removeData(data: CategoryItem) {
        guard let index = selectedCategory.value.firstIndex(where: {$0.description == data.description}) else {
            return
        }
        selectedCategory.value.remove(at: index)
    }
    
    /// 특정 카테고리 항목을 받아옵니다.
    func getCategoryItem(at index: Int) -> CategoryItem {
        return categoryType.allcases[index]
    }
    
    /// 포함되어 있는지 확인 후 Boolean 반환
    func isCategorySelected(categoryItem: CategoryItem) -> Bool {
        return selectedCategory.value.contains { item in
            item.description == categoryItem.description
        }
    }
}
