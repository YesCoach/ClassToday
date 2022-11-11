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
}

extension DefaultClassItemRepository: ClassItemRepository {

    func upload(classItem: ClassItem, completion: @escaping () -> ()) {
        firestoreManager.upload(classItem: classItem, completion: completion)
    }
    
    func fetchClassItems(completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.fetch(completion: completion)
    }
    
    func fetchClassItems(location: Location?, completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.fetch(location, completion: completion)
    }
    
    func fetchClassItems(keyword: String, completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.fetch(keyword: keyword, completion: completion)
    }
    
    func fetchClassItem(id: String, completion: @escaping (ClassItem) -> ()) {
        firestoreManager.fetch(classItemId: id, completion: completion)
    }
    
    func fetchClassItems(categories: [String], completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.categorySort(categories: categories, completion: completion)
    }
    
    func fetchClassItems(keyword: String, category: String, completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.categorySort(keyword: keyword, category: category, completion: completion)
    }
    
    func fetchClassItems(keyword: String, categories: [String], completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.categorySort(keyword: keyword, categories: categories, completion: completion)
    }
    
    func fetchClassItems(starList: [String]?, completion: @escaping ([ClassItem]) -> ()) {
        firestoreManager.starSort(starList: starList, completion: completion)
    }
    
    func update(classItem: ClassItem, completion: @escaping () -> ()) {
        firestoreManager.update(classItem: classItem, completion: completion)
    }
    
    func delete(classItem: ClassItem, completion: @escaping () -> ()) {
        firestoreManager.delete(classItem: classItem, completion: completion)
    }
}
