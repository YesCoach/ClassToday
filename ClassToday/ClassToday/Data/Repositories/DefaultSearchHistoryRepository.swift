//
//  DefaultSearchHistoryRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/16.
//

import Foundation

final class DefaultSearchHistoryRepository {

    private let searchHistoryPersistentStorage: SearchHistoryStorage

    init(searchHistoryPersistentStorage: SearchHistoryStorage) {
        self.searchHistoryPersistentStorage = searchHistoryPersistentStorage
    }
}

extension DefaultSearchHistoryRepository: SearchHistoryRepository {
    func saveSearchHistoryList(historyList: [SearchHistory]) {
        searchHistoryPersistentStorage.saveSearchHistoryList(historyList: historyList)
    }

    func loadSearchHistoryList() -> [SearchHistory] {
        return searchHistoryPersistentStorage.loadSearchHistoryList()
    }
}
