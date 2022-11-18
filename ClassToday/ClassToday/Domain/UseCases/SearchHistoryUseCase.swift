//
//  SearchClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/16.
//

import Foundation

protocol SearchHistoryUseCase {
    func saveSearchHistoryList(historyList: [SearchHistory])
    func loadSearchHistoryList() -> [SearchHistory]
}

final class DefaultSearchHistoryUseCase: SearchHistoryUseCase {

    private let searchHistoryRepository: SearchHistoryRepository

    init(searchHistoryRepository: SearchHistoryRepository) {
        self.searchHistoryRepository = searchHistoryRepository
    }

    func saveSearchHistoryList(historyList: [SearchHistory]) {
        searchHistoryRepository.saveSearchHistoryList(historyList: historyList)
    }
    func loadSearchHistoryList() -> [SearchHistory] {
        return searchHistoryRepository.loadSearchHistoryList()
    }
}
