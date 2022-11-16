//
//  ClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol FetchClassItemUseCase {
    func excute(param: ClassItemQuery.FetchItems, completion: @escaping ([ClassItem]) -> ())
    func excute(param: ClassItemQuery.FetchItem, completion: @escaping (ClassItem) -> ())
}

final class DefaultFetchClassItemUseCase: FetchClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    func excute(param: ClassItemQuery.FetchItems, completion: @escaping ([ClassItem]) -> ()) {
        classItemRepository.fetchItems(param: param, completion: completion)
    }

    func excute(param: ClassItemQuery.FetchItem, completion: @escaping (ClassItem) -> ()) {
        classItemRepository.fetchItem(param: param, completion: completion)
    }
}
