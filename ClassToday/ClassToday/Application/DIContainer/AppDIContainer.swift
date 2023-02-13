//
//  AppDIContainer.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/16.
//

import Foundation

final class AppDIContainer {

    // MARK: - DIContainers
    func makeDIContainer() -> DIContainer {
        let dependencies = DIContainer.Dependencies(
            apiDataTransferService: .shared,
            imageDataTransferService: .shared
        )

        return DIContainer(dependencies: dependencies)
    }
}
