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

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeFetchClassItemUseCase() -> FetchClassItemUseCase {
        return DefaultFetchClassItemUseCase(classItemRepository: makeClassItemRepository())
    }

    // MARK: - Repositories
    func makeClassItemRepository() -> ClassItemRepository {
        return DefaultClassItemRepository(firestoreManager: dependencies.apiDataTransferService)
    }

    // MARK: - Main
    func makeMainViewController() -> MainViewController {
        return MainViewController(viewModel: DefaultMainViewModel(fetchClassItemUseCase: makeFetchClassItemUseCase()))
    }
}
