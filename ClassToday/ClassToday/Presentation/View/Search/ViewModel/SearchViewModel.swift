//
//  SearchViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/17.
//

import Foundation

protocol SearchViewModelInput {
    func addSearchHistory(text: String)
    func removeSearchHistory(at index: Int)
    func clearSearchHistory()
    func didSelectItem(at index: Int)
    func didSearchItem(with text: String)
}

protocol SearchViewModelOutput {
    var searchHistoryList: CustomObservable<[SearchHistory]> { get }
    var searchResultViewController: CustomObservable<SearchResultViewController?> { get }
}

protocol SearchViewModel: SearchViewModelInput, SearchViewModelOutput { }

public class DefaultSearchViewModel: SearchViewModel {

    private let searchHistoryUseCase: SearchHistoryUseCase

    // MARK: - OUTPUT
    let searchHistoryList: CustomObservable<[SearchHistory]> = CustomObservable([])
    let searchResultViewController: CustomObservable<SearchResultViewController?> = CustomObservable(nil)

    // MARK: - Init
    init(searchHistoryUseCase: SearchHistoryUseCase) {
        self.searchHistoryUseCase = searchHistoryUseCase
        loadSearchHistory()
    }

    //MARK: - search history save/load
    /// UserDefaults에 검색기록을 저장합니다.
    private func saveSearchHistory() {
        searchHistoryUseCase.saveSearchHistoryList(historyList: searchHistoryList.value)
    }

    /// UserDefaults로부터 검색기록을 불러옵니다.
    private func loadSearchHistory() {
        searchHistoryList.value = searchHistoryUseCase.loadSearchHistoryList()
    }
}

// MARK: - INPUT
extension DefaultSearchViewModel {
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

    func didSelectItem(at index: Int) {
        let searchKeyword = searchHistoryList.value[index].text
        searchResultViewController.value = AppDIContainer()
            .makeDIContainer()
            .makeSearchResultViewController(searchKeyword: searchKeyword)
    }

    func didSearchItem(with text: String) {
        searchResultViewController.value = AppDIContainer()
            .makeDIContainer()
            .makeSearchResultViewController(searchKeyword: text)
    }
}
