//
//  DefaultClassItemRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

final class DefaultClassItemRepository {

    private let firestoreManager: FirestoreManager

    init(firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.firestoreManager = firestoreManager
    }
    
    deinit {
        print("deinit!!!!!!")
    }
}

extension DefaultClassItemRepository: ClassItemRepository {
    func create(param: ClassItemQuery.CreateItem, completion: @escaping () -> ()) {
        switch param {
        case .create(let item):
            firestoreManager.upload(classItem: item, completion: completion)
        }
    }

    func fetchItem(param: ClassItemQuery.FetchItem, completion: @escaping (ClassItem) -> ()) {
        switch param {
        case .fetchItem(let id):
            firestoreManager.fetch(classItemId: id, completion: completion)
        }
    }

    func fetchItems(param: ClassItemQuery.FetchItems, completion: @escaping ([ClassItem]) -> ()) {
        switch param {
        case .fetchItems:
            firestoreManager.fetch(completion: completion)
        case .fetchByLocation(let location):
            firestoreManager.fetch(location: location, completion: completion)
        case .fetchByKeyword(let keyword):
            firestoreManager.fetch(keyword: keyword, completion: completion)
        case .fetchByKeywordSearch(let keyword, let searchKeyword):
            firestoreManager.fetch(keyword: keyword, searchKeyword: searchKeyword, completion: completion)
        case .fetchByKeywordCategory(let keyword, let category):
            firestoreManager.categorySort(keyword: keyword, category: category, completion: completion)
        case .fetchByKeywordCategories(let keyword, let categories):
            firestoreManager.categorySort(keyword: keyword, categories: categories, completion: completion)
        case .fetchByCategories(let categories):
            firestoreManager.categorySort(categories: categories, completion: completion)
        case .fetchByStarlist(let starlist):
            firestoreManager.starSort(starList: starlist, completion: completion)
        }
    }

    func update(param: ClassItemQuery.UpdateItem, completion: @escaping () -> ()) {
        switch param {
        case .update(let item):
            firestoreManager.update(classItem: item, completion: completion)
        }
    }

    func delete(param: ClassItemQuery.DeleteItem, completion: @escaping () -> ()) {
        switch param {
        case .delete(let item):
            firestoreManager.delete(classItem: item, completion: completion)
        }
    }
}
