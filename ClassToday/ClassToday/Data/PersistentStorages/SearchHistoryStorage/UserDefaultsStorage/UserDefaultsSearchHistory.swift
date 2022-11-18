//
//  UserDefaultsSearchHistory.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/16.
//

import Foundation

final class UserDefaultsSearchHistory {
    private let userDefaults: UserDefaults
    private let searchHistoryKey = "searchHistory"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsSearchHistory: SearchHistoryStorage {
    func saveSearchHistoryList(historyList: [SearchHistory]) {
        let mappedHistory = historyList.map { $0.text }
        userDefaults.set(mappedHistory, forKey: searchHistoryKey)
    }

    func loadSearchHistoryList() -> [SearchHistory] {
        guard let data = userDefaults.object(forKey: searchHistoryKey) as? [String] else {
            return []
        }
        let searchHistoryList = data.map { SearchHistory(text: $0) }
        return searchHistoryList
    }
}
