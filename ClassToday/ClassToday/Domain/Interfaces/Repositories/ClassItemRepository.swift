//
//  ClassItemRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol ClassItemRepository {

    // MARK: - POST
    func create(param: ClassItemQuery.CreateItem, completion: @escaping() -> ())

    // MARK: - GET
    func fetchItem(param: ClassItemQuery.FetchItem, completion: @escaping (ClassItem) -> ())
    func fetchItems(param: ClassItemQuery.FetchItems, completion: @escaping ([ClassItem]) -> ())

    // MARK: - PUT
    func update(param: ClassItemQuery.UpdateItem, completion: @escaping() -> ())

    // MARK: - DELETE
    func delete(param: ClassItemQuery.DeleteItem, completion: @escaping() -> ())
}
