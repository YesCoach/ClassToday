//
//  SearchViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/17.
//

import Foundation

public class SearchViewModel {
    
    private let userDefaults = UserDefaults.standard
    var searchHistoryList: Observable<[SearchHistory]> = Observable([])
    
    init() {
        loadSearchHistory()
    }
    
    /// 검색 기록을 추가합니다.
    func addSearchHistory(text: String) {
        let newSearchHistory = SearchHistory(text: text)
        searchHistoryList.value.insert(newSearchHistory, at: 0)
        saveSearchHistory()
    }
    
    /// 검색 기록을 삭제합니다.
    func removeSearchHistory(at index: Int) {
        searchHistoryList.value.remove(at: index)
        saveSearchHistory()
    }
    
    /// 검색 기록을 초기화합니다.
    func clearSearchHistory() {
        searchHistoryList.value.removeAll()
        saveSearchHistory()
    }
    
    //MARK: - search history save/load
    /// UserDefaults에 검색기록을 저장합니다.
    private func saveSearchHistory() {
        let searchHistory = searchHistoryList.value.map {
            [
                "text": $0.text
            ]
        }
        userDefaults.set(searchHistory, forKey: "searchHistoryList")
    }
    
    /// UserDefaults로부터 검색기록을 불러옵니다.
    private func loadSearchHistory() {
        guard let data = userDefaults.object(forKey: "searchHistoryList") as? [[String: Any]] else { return }
        searchHistoryList.value = data.compactMap {
            guard let text = $0["text"] as? String else { return nil }
            return SearchHistory(text: text)
        }
    }
    
    /// 선택한 검색기록의 상세 View Controller를 반환합니다.
    func searchResultViewController(at index: Int) -> SearchResultViewController {
        let searchResultViewController = SearchResultViewController(keyword: searchHistoryList.value[index].text)
        return searchResultViewController
    }
    
    /// 검색한 텍스트의 상세 View Controller를 반환합니다.
    func searchResultViewController(with text: String?) -> SearchResultViewController {
        let searchResultViewController = SearchResultViewController(keyword: text ?? "")
        return searchResultViewController
    }
}
