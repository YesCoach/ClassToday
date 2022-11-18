//
//  ClassItemQuery.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

struct ClassItemQuery {
    enum FetchItem {
        case fetchItem(id: String)
    }
    enum FetchItems {
        case fetchItems
        case fetchByLocation(location: Location?)
        case fetchByKeyword(keyword: String)
        case fetchByKeywordSearch(keyword: String, searchKeyword: String)
        case fetchByKeywordCategory(keyword: String, category: String)
        case fetchByKeywordCategories(keyword: String, categories: [String])
        case fetchByCategories(categories: [String])
        case fetchByStarlist(starlist: [String]?)
    }
    enum CreateItem {
        case create(item: ClassItem)
    }
    enum UpdateItem {
        case update(item: ClassItem)
    }
    enum DeleteItem {
        case delete(item: ClassItem)
    }
}
