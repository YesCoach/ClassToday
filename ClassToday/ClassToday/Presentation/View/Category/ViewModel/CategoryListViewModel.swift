//
//  CategoryListViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/18.
//

import UIKit
import RxSwift

protocol CategoryListViewModelInput {
    func didSelectItemAt(index: Int)
}

protocol CategoryListViewModelOutput {
    var categoryList: [CategoryItem] { get }
    var categoryListCount: Int { get }
    var categoryDetailViewController: BehaviorSubject<CategoryDetailViewController?> { get }
}

protocol CategoryListViewModel: CategoryListViewModelInput, CategoryListViewModelOutput {}

public class DefaultCategoryListViewModel: CategoryListViewModel {
    
    private let categoryType: CategoryType
    
    // MARK: - OUTPUT
    let categoryList: [CategoryItem]
    let categoryListCount: Int
    let categoryDetailViewController: BehaviorSubject<CategoryDetailViewController?> = BehaviorSubject(value: nil)
    
    init(categoryType: CategoryType) {
        self.categoryType = categoryType
        categoryList = categoryType.allcases
        categoryListCount = categoryType.count
    }
}

// MARK: - INPUT
extension DefaultCategoryListViewModel {
    func didSelectItemAt(index: Int) {
        categoryDetailViewController.onNext(
            AppDIContainer()
                .makeDIContainer()
                .makeCategoryDetailViewController(categoryItem: categoryType.allcases[index])
        )
    }
}
