//
//  ClassItemRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol ClassItemRepository {

    // MARK: - Create
    func upload(classItem: ClassItem, completion: @escaping() -> ())

    // MARK: - Read
    func fetchClassItems(completion: @escaping ([ClassItem]) -> ())
    func fetchClassItems(location: Location?, completion: @escaping ([ClassItem]) -> ())
    func fetchClassItems(keyword: String, completion: @escaping ([ClassItem]) -> ())
    func fetchClassItem(id: String, completion: @escaping (ClassItem) -> ())

    func fetchClassItems(categories: [String], completion: @escaping ([ClassItem]) -> ())
    func fetchClassItems(keyword: String, category: String, completion: @escaping ([ClassItem]) -> ())
    func fetchClassItems(keyword: String, categories: [String], completion: @escaping ([ClassItem]) -> ())

    func fetchClassItems(starList: [String]?, completion: @escaping ([ClassItem]) -> ())

    // MARK: - Update
    func update(classItem: ClassItem, completion: @escaping() -> ())

    // MARK: - Delete
    func delete(classItem: ClassItem, completion: @escaping() -> ())
}
