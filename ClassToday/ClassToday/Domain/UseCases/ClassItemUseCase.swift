//
//  ClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol ClassItemUseCase {
    func excute(param: FetchItemsParam, completion: @escaping ([ClassItem]) -> ())
}

final class DefaultClassItemUseCase: ClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItempRepository: ClassItemRepository) {
        self.classItemRepository = classItempRepository
    }

    func excute(param: FetchItemsParam, completion: @escaping ([ClassItem]) -> ()) {
        switch param {
        case .fetchAll:
            classItemRepository.fetchClassItems(completion: completion)
        case .fetchByLocation(let location):
            classItemRepository.fetchClassItems(location: location, completion: completion)
        case .fetchByKeyword(let keyword):
            classItemRepository.fetchClassItems(keyword: keyword, completion: completion)
        case .fetchByKeywordCategory(let keyword, let category):
            classItemRepository.fetchClassItems(keyword: keyword, category: category, completion: completion)
        case .fetchByKeywordCategories(let keyword, let categories):
            classItemRepository.fetchClassItems(keyword: keyword, categories: categories, completion: completion)
        case .fetchByCategories(let categories):
            classItemRepository.fetchClassItems(categories: categories, completion: completion)
        case .fetchByStarlist(let starlist):
            classItemRepository.fetchClassItems(starList: starlist, completion: completion)
        }
    }
}
