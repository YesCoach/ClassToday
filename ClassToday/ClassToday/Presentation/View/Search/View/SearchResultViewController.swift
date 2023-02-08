//
//  SearchResultViewController.swift
//  ClassToday
//
//  Created by poohyhy on 2022/04/19.
//

import UIKit
import SnapKit
import RxSwift

class SearchResultViewController: UIViewController {
    
    //MARK: - NavigationBar Components
    private lazy var leftBarButton: UIBarButtonItem = {
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBackButton))
        return leftBarButton
    }()
    
    //MARK: - Main View Components
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "모두", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "구매글", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "판매글", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(didChangedSegmentControlValue(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var classItemTableView: UITableView = {
        let classItemTableView = UITableView()
        classItemTableView.refreshControl = refreshControl
        classItemTableView.rowHeight = 150.0
        classItemTableView.dataSource = self
        classItemTableView.delegate = self
        classItemTableView.register(ClassItemTableViewCell.self, forCellReuseIdentifier: ClassItemTableViewCell.identifier)
        return classItemTableView
    }()
    
    private lazy var navigationTitle: UILabel = {
        let navigationTitle = UILabel()
        navigationTitle.font = .systemFont(ofSize: 18.0, weight: .semibold)
        navigationTitle.textColor = .black
        return navigationTitle
    }()
    
    private lazy var nonAuthorizationAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "위치정보 권한을 허용해주세요."
        label.isHidden = true
        label.textColor = UIColor.systemGray
        return label
    }()
    
    private lazy var nonDataAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 수업 아이템이 없어요"
        label.isHidden = true
        label.textColor = UIColor.systemGray
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
        refreshControl.tintColor = .mainColor
        return refreshControl
    }()
    
    // MARK: Properties
    private var viewModel: SearchResultViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        setLayout()
        bindViewModel()
    }
    
    private func bindViewModel() {
        /// 수업아이템 바인딩
        viewModel.outPutData
            .bind { [weak self] classItems in
                self?.classItemTableView.reloadData()
                if classItems.isEmpty {
                    self?.nonDataAlertLabel.isHidden = false
                } else {
                    self?.nonDataAlertLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)

        /// 지역명 패칭 진행중인지 바인딩
        viewModel.isNowLocationFetching
            .asDriver()
            .drive { [weak self] isFetching in
                isFetching ?
                self?.classItemTableView.refreshControl?.beginRefreshing() :
                self?.classItemTableView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)

        /// 수업 아이템 패칭중인지 바인딩
        viewModel.isNowDataFetching
            .asDriver()
            .drive { [weak self] isFetching in
                if isFetching {
                    self?.classItemTableView.refreshControl?.beginRefreshing()
                    self?.nonDataAlertLabel.isHidden = true
                } else {
                    self?.classItemTableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        viewModel.classDetailViewController
            .bind { [weak self] viewController in
                if let viewController = viewController {
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftBarButton
        navigationTitle.text = viewModel.searchKeyword
        navigationItem.titleView = navigationTitle
    }
}

//MARK: - objc functions
private extension SearchResultViewController {
    @objc func didChangedSegmentControlValue(_ sender: UISegmentedControl) {
        viewModel.didSelectSegmentControl(segmentControlIndex: sender.selectedSegmentIndex)
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func beginRefresh() {
        print("beginRefresh!")
        viewModel.refreshClassItemList()
    }
}

//MARK: - set autolayout
private extension SearchResultViewController {
    func setLayout() {
        [
            segmentedControl,
            classItemTableView
        ].forEach { view.addSubview($0) }
        [
            nonAuthorizationAlertLabel,
            nonDataAlertLabel
        ].forEach { classItemTableView.addSubview($0) }
        segmentedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        classItemTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        nonAuthorizationAlertLabel.snp.makeConstraints {
            $0.center.equalTo(view)
        }
        nonDataAlertLabel.snp.makeConstraints {
            $0.center.equalTo(view)
        }
    }
}

//MARK: - tableview datasource
extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = try? viewModel.outPutData.value().count else {
            return 0
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ClassItemTableViewCell.identifier,
            for: indexPath
        ) as? ClassItemTableViewCell,
              let classItem = try? viewModel.outPutData.value()[indexPath.row]
        else { return UITableViewCell() }

        cell.configureWith(viewModel: ClassItemViewModel(classItem: classItem)) { image in
            if let image = image {
                DispatchQueue.main.async {
                    if indexPath == tableView.indexPath(for: cell) {
                        cell.thumbnailView.image = image
                    }
                }
            }
        }
        return cell
    }
}

//MARK: - TableView Delegate
extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
