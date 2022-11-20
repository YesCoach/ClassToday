//
//  DIContainer.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/15.
//

import Foundation

final class DIContainer {
    
    struct Dependencies {
        let apiDataTransferService: FirestoreManager
    }

    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var searchHistoryStorage: SearchHistoryStorage = UserDefaultsSearchHistory(userDefaults: .standard)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeFetchClassItemUseCase() -> FetchClassItemUseCase {
        return DefaultFetchClassItemUseCase(classItemRepository: makeClassItemRepository())
    }

    func makeSearchHistoryUseCase() -> SearchHistoryUseCase {
        return DefaultSearchHistoryUseCase(searchHistoryRepository: makeSearchHistoryRepository())
    }

    // MARK: - Repositories
    func makeClassItemRepository() -> ClassItemRepository {
        return DefaultClassItemRepository(firestoreManager: dependencies.apiDataTransferService)
    }

    func makeSearchHistoryRepository() -> SearchHistoryRepository {
        return DefaultSearchHistoryRepository(searchHistoryPersistentStorage: searchHistoryStorage)
    }

    // MARK: - Main
    func makeMainViewController() -> MainViewController {
        return MainViewController(viewModel: makeMainViewModel())
    }

    func makeMainViewModel() -> MainViewModel {
        return DefaultMainViewModel(fetchClassItemUseCase: makeFetchClassItemUseCase())
    }

    // MARK: - Search View
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(viewModel: makeSearchViewModel())
    }

    func makeSearchViewModel() -> SearchViewModel {
        return DefaultSearchViewModel(searchHistoryUseCase: makeSearchHistoryUseCase())
    }

    // MARK: - Search Result View
    func makeSearchResultViewController(searchKeyword: String) -> SearchResultViewController {
        return SearchResultViewController(viewModel: makeSearchResultViewModel(searchKeyword: searchKeyword))
    }

    func makeSearchResultViewModel(searchKeyword: String) -> SearchResultViewModel {
        return DefaultSearchResultViewModel(fetchClassItemUseCase: makeFetchClassItemUseCase(),
                                            searchKeyword: searchKeyword)
    }

    // MARK: - Category List View
    func makeCategoryListViewController(categoryType: CategoryType) -> CategoryListViewController {
        return CategoryListViewController(viewModel: makeCategoryListViewModel(categoryType: categoryType))
    }

    func makeCategoryListViewModel(categoryType: CategoryType) -> CategoryListViewModel {
        return DefaultCategoryListViewModel(categoryType: categoryType)
    }

    // MARK: - Category View
    func makeCategoryDetailViewController(categoryItem: CategoryItem) -> CategoryDetailViewController {
        return CategoryDetailViewController(viewModel: makeCategoryDetailViewModel(categoryItem: categoryItem))
    }

    func makeCategoryDetailViewModel(categoryItem: CategoryItem) -> CategoryDetailViewModel {
        return DefaultCategoryDetailViewModel(fetchClassItemUseCase: makeFetchClassItemUseCase(), categoryItem: categoryItem)
    }
}
