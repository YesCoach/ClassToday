//
//  searchViewController.swift
//  ClassToday
//
//  Created by poohyhy on 2022/04/19.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {
    //MARK: - NavigationBar Components
    private lazy var toolBarKeyboard: UIToolbar = {
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let blankSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(didTapDoneButton))
        toolBarKeyboard.items = [blankSpace, doneButton]
        toolBarKeyboard.tintColor = UIColor.mainColor
        return toolBarKeyboard
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        searchBar.placeholder = "검색어를 입력해주세요"
        searchBar.inputAccessoryView = toolBarKeyboard
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var leftBarButton: UIBarButtonItem = {
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBackButton))
        return leftBarButton
    }()

    func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.titleView = searchBar
    }
    
    //MARK: - UI Components
    
    private lazy var recentLabel: UILabel = {
        let recentLabel = UILabel()
        recentLabel.text = "최근 검색어"
        recentLabel.font = .systemFont(ofSize: 24.0, weight: .bold)
        return recentLabel
    }()
    
    private lazy var recentClearButton: UIButton = {
        let recentClearButton = UIButton()
        recentClearButton.setTitle("전체삭제", for: .normal)
        recentClearButton.setTitleColor(.lightGray, for: .normal)
        recentClearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        return recentClearButton
    }()
    
    private lazy var searchRecentTableView: UITableView = {
        let searchRecentTableView = UITableView()
        searchRecentTableView.delegate = self
        searchRecentTableView.dataSource = self
        searchRecentTableView.rowHeight = 44.0
        searchRecentTableView.register(SearchRecentTableViewCell.self, forCellReuseIdentifier: SearchRecentTableViewCell.identifier)
        return searchRecentTableView
    }()

    private let viewModel: SearchViewModel

    // MARK: - Init
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        layout()
        bindingViewModel()
    }

    private func bindingViewModel() {
        viewModel.searchHistoryList.bind { [weak self] searchHistory in
            self?.searchRecentTableView.reloadData()
        }
        viewModel.searchResultViewController.bind { [weak self] viewController in
            if let viewController = viewController {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

//MARK: - objc functions
private extension SearchViewController {
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapDoneButton() {
        searchBar.resignFirstResponder()
    }
    
    @objc func didTapClearButton() {
        viewModel.clearSearchHistory()
    }
}

//MARK: - set autolayout
private extension SearchViewController {
    func layout() {
        [
            recentLabel,
            recentClearButton,
            searchRecentTableView
        ].forEach { view.addSubview($0) }
        
        let commonInset: CGFloat = 16.0
        
        recentLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(commonInset)
            $0.trailing.equalTo(recentClearButton.snp.leading)
        }
        recentClearButton.snp.makeConstraints {
            $0.height.equalTo(28.0)
            $0.trailing.equalToSuperview().inset(commonInset)
            $0.bottom.equalTo(searchRecentTableView.snp.top)
        }
        searchRecentTableView.snp.makeConstraints {
            $0.top.equalTo(recentLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

//MARK: - SearchBar delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        viewModel.addSearchHistory(text: text)
        viewModel.didSearchItem(with: text)
    }
}

//MARK: - tableview datasource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchHistoryList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchRecentTableViewCell.identifier, for: indexPath) as? SearchRecentTableViewCell else { return UITableViewCell() }
        let searchHistory = viewModel.searchHistoryList.value[indexPath.row]
        cell.configure(with: searchHistory.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.removeSearchHistory(at: indexPath.row)
    }
}

//MARK: - tableview delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
