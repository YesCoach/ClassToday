//
//  SearchViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/17.
//

import Foundation
import RxSwift

protocol SearchViewModelInput {
    func addSearchHistory(text: String)
    func removeSearchHistory(at index: Int)
    func clearSearchHistory()
    func didSelectItem(at index: Int)
    func didSearchItem(with text: String)
}

protocol SearchViewModelOutput {
    var searchHistoryList: BehaviorSubject<[SearchHistory]> { get }
    var searchResultViewController: BehaviorSubject<SearchResultViewController?> { get }
}

protocol SearchViewModel: SearchViewModelInput, SearchViewModelOutput { }

public class DefaultSearchViewModel: SearchViewModel {

    private let searchHistoryUseCase: SearchHistoryUseCase

    // MARK: - OUTPUT
    let searchHistoryList: BehaviorSubject<[SearchHistory]> = BehaviorSubject(value: [])
    let searchResultViewController: BehaviorSubject<SearchResultViewController?> = BehaviorSubject(value: nil)

    let disposeBag = DisposeBag()

    // MARK: - Init
    init(searchHistoryUseCase: SearchHistoryUseCase) {
        self.searchHistoryUseCase = searchHistoryUseCase
        loadSearchHistory()
    }

    //MARK: - search history save/load
    /// UserDefaults에 검색기록을 저장합니다.
    private func saveSearchHistory() {
        guard let searchHistoryListValue = try? searchHistoryList.value() else { return }
        searchHistoryUseCase.saveSearchHistoryList(historyList: searchHistoryListValue)
    }

    /// UserDefaults로부터 검색기록을 불러옵니다.
    private func loadSearchHistory() {
        searchHistoryList.onNext(searchHistoryUseCase.loadSearchHistoryList())
    }
}

// MARK: - INPUT
extension DefaultSearchViewModel {
    /// 검색 기록을 추가합니다.
    func addSearchHistory(text: String) {
        let newSearchHistory = SearchHistory(text: text)

        guard var searchHistoryListValue = try? searchHistoryList.value() else { return }
        searchHistoryListValue.insert(newSearchHistory, at: 0)
        searchHistoryList.onNext(searchHistoryListValue)
        saveSearchHistory()
    }

    /// 검색 기록을 삭제합니다.
    func removeSearchHistory(at index: Int) {
        guard var searchHistoryListValue = try? searchHistoryList.value() else { return }
        searchHistoryListValue.remove(at: index)
        searchHistoryList.onNext(searchHistoryListValue)
        saveSearchHistory()
    }

    /// 검색 기록을 초기화합니다.
    func clearSearchHistory() {
        searchHistoryList.onNext([])
        saveSearchHistory()
    }

    func didSelectItem(at index: Int) {
        guard let searchHistoryListValue = try? searchHistoryList.value() else { return }
        let searchKeyword = searchHistoryListValue[index].text
        
        searchResultViewController.onNext(
            AppDIContainer()
                .makeDIContainer()
                .makeSearchResultViewController(searchKeyword: searchKeyword)
        )
        searchResultViewController.onNext(nil)
    }

    func didSearchItem(with text: String) {
        searchResultViewController.onNext(
            AppDIContainer()
                .makeDIContainer()
                .makeSearchResultViewController(searchKeyword: text)
        )
        searchResultViewController.onNext(nil)
    }
}
