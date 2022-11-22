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
        let imageDataTransferService: StorageManager
    }

    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var searchHistoryStorage: SearchHistoryStorage = UserDefaultsSearchHistory(userDefaults: .standard)

    // MARK: - Framework Manager
    lazy var locationManager: LocationManager = LocationManager.shared
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeFetchClassItemUseCase() -> FetchClassItemUseCase {
        return DefaultFetchClassItemUseCase(classItemRepository: makeClassItemRepository())
    }

    func makeUploadClassItemUseCase() -> UploadClassItemUseCase {
        return DefaultUploadClassItemUseCase(classItemRepository: makeClassItemRepository())
    }

    func makeLocationUseCase() -> LocationUseCase {
        return DefaultLocationUseCase(locationManager: locationManager)
    }

    func makeImageUseCase() -> ImageUseCase {
        return DefaultImageUseCase(imageRepository: makeImageRepository())
    }

    func makeAddressTransferUseCase() -> AddressTransferUseCase {
        return DefaultAddressTransferUseCase(addressTransferRepository: makeAddressTransferRepository())
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

    func makeImageRepository() -> ImageRepository {
        return DefaultImageRepository(storageManager: dependencies.imageDataTransferService)
    }

    func makeAddressTransferRepository() -> AddressTransferRepository {
        return DefaultAddressTransferRepository(naverMapAPIProvider: NaverMapAPIProvider())
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

    // MARK: - Star View
    func makeStarViewController() -> StarViewController {
        return StarViewController(viewModel: makeStarViewModel())
    }

    func makeStarViewModel() -> StarViewModel {
        return DefaultStarViewModel(fetchUseCase: makeFetchClassItemUseCase())
    }
    
    // MARK: - Class Enroll Modify View
    func makeClassEnrollViewController(classItempType: ClassItemType) -> ClassEnrollViewController {
        return ClassEnrollViewController(viewModel: makeClassEnrollModifyViewModel(classItemType: classItempType))
    }

    func makeClassModifyViewController(classItem: ClassItem) -> ClassModifyViewController {
        return ClassModifyViewController(viewModel: makeClassEnrollModifyViewModel(classItem: classItem))
    }

    func makeClassEnrollModifyViewModel(classItemType: ClassItemType) -> ClassEnrollModifyViewModel {
        return DefaultClassEnrollModifyViewModel(uploadClassItemUseCase: makeUploadClassItemUseCase(),
                                                 imageUseCase: makeImageUseCase(),
                                                 locationUseCase: makeLocationUseCase(),
                                                 addressTransferUseCase: makeAddressTransferUseCase(),
                                                 classItemType: classItemType)
    }

    func makeClassEnrollModifyViewModel(classItem: ClassItem) -> ClassEnrollModifyViewModel {
        return DefaultClassEnrollModifyViewModel(uploadClassItemUseCase: makeUploadClassItemUseCase(),
                                                 imageUseCase: makeImageUseCase(),
                                                 locationUseCase: makeLocationUseCase(),
                                                 addressTransferUseCase: makeAddressTransferUseCase(),
                                                 classItem: classItem)
    }
    
    // MARK: - Map Selection View
    func makeMapSelectionViewController() -> MapSelectionViewController {
        return MapSelectionViewController(viewModel: makeMapSelectionViewModel())
    }

    func makeMapSelectionViewModel() -> MapSelectionViewModel {
        return DefaultMapSelectionViewModel(addressTransferUseCase: makeAddressTransferUseCase(),
                                            locationUseCase: makeLocationUseCase())
    }
}
