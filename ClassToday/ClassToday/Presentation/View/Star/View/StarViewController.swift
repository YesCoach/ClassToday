//
//  StarViewController.swift
//  ClassToday
//
//  Created by poohyhy on 2022/04/20.
//

import UIKit
import SnapKit
import RxSwift

class StarViewController: UIViewController {
    //MARK: - NavigationBar Components
    private lazy var leftBarItem: UIBarButtonItem = {
        let leftBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBackButton))
        return leftBarItem
    }()
    
    private lazy var navigationTitle: UILabel = {
        let navigationTitle = UILabel()
        navigationTitle.text = "즐겨찾기"
        navigationTitle.font = .systemFont(ofSize: 18.0, weight: .semibold)
        navigationTitle.textColor = .black
        return navigationTitle
    }()
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.titleView = navigationTitle
    }
    
    //MARK: TableView
    private lazy var classItemTableView: UITableView = {
        let classItemTableView = UITableView()
        classItemTableView.refreshControl = refreshControl
        classItemTableView.rowHeight = 150.0
        classItemTableView.dataSource = self
        classItemTableView.delegate = self
        classItemTableView.register(ClassItemTableViewCell.self, forCellReuseIdentifier: ClassItemTableViewCell.identifier)
        return classItemTableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
        refreshControl.tintColor = .mainColor
        return refreshControl
    }()
    
    private lazy var nonDataAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 수업 아이템이 없어요"
        label.textColor = UIColor.systemGray
        return label
    }()
    
    // MARK: Properties
    private let viewModel: StarViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: StarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        layout()
        bindViewModel()
    }
    
    // MARK: - Method
    func bindViewModel() {
        viewModel.currentUser
            .bind { [weak self] user in
                if let _ = user {
                    self?.viewModel.fetchData()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.data
            .bind { [weak self] data in
                self?.classItemTableView.reloadData()
                if data.isEmpty {
                    self?.nonDataAlertLabel.isHidden = false
                } else {
                    self?.nonDataAlertLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isNowDataFetching
            .asDriver()
            .drive(onNext: { [weak self] isTrue in
                if isTrue {
                    self?.refreshControl.beginRefreshing()
                    self?.nonDataAlertLabel.isHidden = true
                } else {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.classDetailViewController
            .bind { [weak self] viewController in
                if let viewController = viewController {
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - objc methods
private extension StarViewController {
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func beginRefresh() {
        viewModel.fetchData()
    }
}

//MARK: - Autolayout
private extension StarViewController {
    func layout() {
        [
            classItemTableView
        ].forEach { view.addSubview($0) }
        classItemTableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        classItemTableView.addSubview(nonDataAlertLabel)
        nonDataAlertLabel.snp.makeConstraints {
            $0.center.equalTo(view)
        }
    }
}

//MARK: - TableView DataSource
extension StarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = try? viewModel.data.value().count else {
            return 0
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ClassItemTableViewCell.identifier,
            for: indexPath
        ) as? ClassItemTableViewCell,
              let classItem = try? viewModel.data.value()[indexPath.row]
        else {
            return UITableViewCell()
        }

        cell.configureWith(viewModel: ClassItemViewModel(classItem: classItem)) { image in
            DispatchQueue.main.async {
                if indexPath == tableView.indexPath(for: cell) {
                    cell.thumbnailView.image = image
                }
            }
        }
        return cell
    }
}

extension StarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
