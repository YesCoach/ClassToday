//
//  ClassItemQuery.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol ClassItemQuery {
    
}

enum FetchItemParam: ClassItemQuery {
    case fetchItem(id: String)
}

enum FetchItemsParam: ClassItemQuery {
    case fetchAll
    case fetchByLocation(location: Location?)
    case fetchByKeyword(keyword: String)
    case fetchByKeywordCategory(keyword: String, category: String)
    case fetchByKeywordCategories(keyword: String, categories: [String])
    case fetchByCategories(categories: [String])
    case fetchByStarlist(starlist: [String]?)
}

enum CreateUpdateDeleteParam: ClassItemQuery {
    case create(item: ClassItem)
    case update(item: ClassItem)
    case delete(item: ClassItem)
}
