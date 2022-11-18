//
//  SearchHistoryStorage.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/16.
//

import Foundation

protocol SearchHistoryStorage {
    func saveSearchHistoryList(historyList: [SearchHistory])
    func loadSearchHistoryList() -> [SearchHistory]
}
