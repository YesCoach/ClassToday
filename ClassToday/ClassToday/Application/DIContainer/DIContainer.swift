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

    lazy var userStorage: UserStorage = UserDefaultsUser()
    lazy var searchHistoryStorage: SearchHistoryStorage = UserDefaultsSearchHistory()

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

    func makeDeleteClassItemUseCase() -> DeleteClassItemUseCase {
        return DefaultDeleteClassItemUseCase(classItemRepository: makeClassItemRepository())
    }

    func makeLocationUseCase() -> LocationUseCase {
        return DefaultLocationUseCase(locationManager: locationManager)
    }

    func makeImageUseCase() -> ImageUseCase {
        return DefaultImageUseCase(imageRepository: makeImageRepository())
    }

    func makeAddressTransferUseCase() -> AddressTransferUseCase {
        return DefaultAddressTransferUseCase(
            addressTransferRepository: makeAddressTransferRepository()
        )
    }

    func makeUserUseCase() -> UserUseCase {
        return DefaultUserUseCase(userRepository: makeUserRepository())
    }

    func makeSearchHistoryUseCase() -> SearchHistoryUseCase {
        return DefaultSearchHistoryUseCase(searchHistoryRepository: makeSearchHistoryRepository())
    }

    func makeChatUseCase() -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: makeChatRepository())
    }

    // MARK: - Repositories

    func makeClassItemRepository() -> ClassItemRepository {
        return DefaultClassItemRepository(firestoreManager: dependencies.apiDataTransferService)
    }

    func makeUserRepository() -> UserRepository {
        return DefaultUserRepository(
            firestoreManager: dependencies.apiDataTransferService,
            userPersistentStorage: userStorage
        )
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

    func makeChatRepository() -> ChatRepository {
        return DefaultChatRepository(firestoreManager: dependencies.apiDataTransferService)
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
        return SearchResultViewController(
            viewModel: makeSearchResultViewModel(searchKeyword: searchKeyword)
        )
    }

    func makeSearchResultViewModel(searchKeyword: String) -> SearchResultViewModel {
        return DefaultSearchResultViewModel(
            fetchClassItemUseCase: makeFetchClassItemUseCase(),
            searchKeyword: searchKeyword
        )
    }

    // MARK: - Category List View

    func makeCategoryListViewController(categoryType: CategoryType) -> CategoryListViewController {
        return CategoryListViewController(
            viewModel: makeCategoryListViewModel(categoryType: categoryType)
        )
    }

    func makeCategoryListViewModel(categoryType: CategoryType) -> CategoryListViewModel {
        return DefaultCategoryListViewModel(categoryType: categoryType)
    }

    // MARK: - Category View

    func makeCategoryDetailViewController(
        categoryItem: CategoryItem
    ) -> CategoryDetailViewController {
        return CategoryDetailViewController(
            viewModel: makeCategoryDetailViewModel(categoryItem: categoryItem)
        )
    }

    func makeCategoryDetailViewModel(categoryItem: CategoryItem) -> CategoryDetailViewModel {
        return DefaultCategoryDetailViewModel(
            fetchClassItemUseCase: makeFetchClassItemUseCase(),
            categoryItem: categoryItem
        )
    }

    // MARK: - Star View

    func makeStarViewController() -> StarViewController {
        return StarViewController(viewModel: makeStarViewModel())
    }

    func makeStarViewModel() -> StarViewModel {
        return DefaultStarViewModel(fetchUseCase: makeFetchClassItemUseCase())
    }
    
    // MARK: - Class Enroll Modify View

    func makeClassEnrollViewController(
        classItempType: ClassItemType
    ) -> ClassEnrollViewController {
        return ClassEnrollViewController(
            viewModel: makeClassEnrollModifyViewModel(classItemType: classItempType)
        )
    }

    func makeClassModifyViewController(classItem: ClassItem) -> ClassModifyViewController {
        return ClassModifyViewController(
            viewModel: makeClassEnrollModifyViewModel(classItem: classItem)
        )
    }

    func makeClassEnrollModifyViewModel(
        classItemType: ClassItemType
    ) -> ClassEnrollModifyViewModel {
        return DefaultClassEnrollModifyViewModel(
            uploadClassItemUseCase: makeUploadClassItemUseCase(),
            imageUseCase: makeImageUseCase(),
            locationUseCase: makeLocationUseCase(),
            addressTransferUseCase: makeAddressTransferUseCase(),
            classItemType: classItemType
        )
    }

    func makeClassEnrollModifyViewModel(classItem: ClassItem) -> ClassEnrollModifyViewModel {
        return DefaultClassEnrollModifyViewModel(
            uploadClassItemUseCase: makeUploadClassItemUseCase(),
            imageUseCase: makeImageUseCase(),
            locationUseCase: makeLocationUseCase(),
            addressTransferUseCase: makeAddressTransferUseCase(),
            classItem: classItem
        )
    }

    func makeEnrollImageViewModel(limitImageCount: Int) -> EnrollImageViewModel {
        return DefaultEnrollImageViewModel(
            imageUseCase: makeImageUseCase(),
            limitImageCount: limitImageCount
        )
    }
    
    // MARK: - Class Detail View

    func makeClassDetailViewController(classItem: ClassItem) -> ClassDetailViewController {
        return ClassDetailViewController(
            classDetailViewModel: makeClassDetailViewModel(classItem: classItem)
        )
    }

    func makeClassDetailViewModel(classItem: ClassItem) -> ClassDetailViewModel {
        // TODO: userDefaultsManager -> Clean Architecture에 맞게 Data 영역으로 리팩토링하기
        return DefaultClassDetailViewModel(
            classItem: classItem,
            deleteClassItemUseCase: makeDeleteClassItemUseCase(),
            uploadClassItemUseCase: makeUploadClassItemUseCase(),
            fetchClassItemUseCase: makeFetchClassItemUseCase(),
            userUseCase: makeUserUseCase(),
            chatUseCase: makeChatUseCase()
        )
    }

    // MARK: - Map Selection View

    func makeMapSelectionViewController() -> MapSelectionViewController {
        return MapSelectionViewController(viewModel: makeMapSelectionViewModel())
    }

    func makeMapSelectionViewModel() -> MapSelectionViewModel {
        return DefaultMapSelectionViewModel(
            addressTransferUseCase: makeAddressTransferUseCase(),
            locationUseCase: makeLocationUseCase()
        )
    }

    // MARK: - Map View

    func makeMapViewController() -> MapViewController {
        return MapViewController(viewModel: makeMapViewModel())
    }

    func makeMapCategorySelectViewController(
        categoryType: CategoryType = .subject
    ) -> MapCategorySelectViewController {
        return MapCategorySelectViewController(
            viewModel: makeMapCategorySelectViewModel(categoryType: categoryType)
        )
    }

    func makeMapViewModel() -> MapViewModel {
        return DefaultMapViewModel(
            userUseCase: makeUserUseCase(),
            locationUseCase: makeLocationUseCase(),
            fetchClassItemUseCase: makeFetchClassItemUseCase()
        )
    }

    func makeMapCategorySelectViewModel(categoryType: CategoryType) -> MapCategorySelectViewModel {
        return DefaultMapCategorySelectViewModel(categoryType: categoryType)
    }
}
