//
//  CategotyDetailViewController.swift
//  ClassToday
//
//  Created by poohyhy on 2022/04/20.
//

import UIKit

class CategoryDetailViewController: UIViewController {
    //MARK: - NavigationBar Components
    private lazy var leftBarItem: UIBarButtonItem = {
        let leftBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBackButton))
        return leftBarItem
    }()
    
    private lazy var navigationTitle: UILabel = {
        let navigationTitle = UILabel()
        navigationTitle.font = .systemFont(ofSize: 18.0, weight: .semibold)
        navigationTitle.textColor = .black
        return navigationTitle
    }()
 
    //MARK: - UI Components
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
        label.textColor = UIColor.systemGray
        return label
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
        refreshControl.tintColor = .mainColor
        return refreshControl
    }()

    // MARK: - Properties
    private var viewModel: CategoryDetailViewModel

    // MARK: - Initialize
    init(viewModel: CategoryDetailViewModel) {
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
        bindingViewModel()
        layout()
    }

    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.titleView = navigationTitle
        navigationTitle.text = viewModel.categoryItem.description
    }

    private func bindingViewModel() {
        viewModel.data.bind { [weak self] data in
            self?.classItemTableView.reloadData()
            if data.isEmpty {
                self?.nonDataAlertLabel.isHidden = false
            }
        }
        viewModel.isNowLocationFetching.bind { [weak self] isTrue in
            if isTrue {
                self?.classItemTableView.refreshControl?.beginRefreshing()
            } else {
                self?.classItemTableView.refreshControl?.endRefreshing()
            }
        }
        viewModel.isNowDataFetching.bind { [weak self] isTrue in
            if isTrue {
                self?.classItemTableView.refreshControl?.beginRefreshing()
                self?.nonDataAlertLabel.isHidden = true
            } else {
                self?.classItemTableView.refreshControl?.endRefreshing()
            }
        }
        viewModel.selectedClassDetailViewController.bind { [weak self] viewController in
            if let viewController = viewController {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

//MARK: - objc functions
private extension CategoryDetailViewController {
    @objc func didChangedSegmentControlValue(_ sender: UISegmentedControl) {
        classItemTableView.reloadData()
    }

    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc func beginRefresh() {
        viewModel.refreshClassItemList()
    }
}

//MARK: - set autolayout
private extension CategoryDetailViewController {
    func layout() {
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
extension CategoryDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch segmentedControl.selectedSegmentIndex {
            case 1:
            count = viewModel.dataBuy.value.count
            case 2:
            count = viewModel.dataSell.value.count
            default:
            count = viewModel.data.value.count
        }
        
        guard nonAuthorizationAlertLabel.isHidden else {
            nonDataAlertLabel.isHidden = true
            return count
        }
        if count == 0 {
            nonDataAlertLabel.isHidden = false
        } else {
            nonDataAlertLabel.isHidden = true
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ClassItemTableViewCell.identifier,
            for: indexPath
        ) as? ClassItemTableViewCell else { return UITableViewCell() }
        let classItem: ClassItem
        switch segmentedControl.selectedSegmentIndex {
            case 1:
            classItem = viewModel.dataBuy.value[indexPath.row]
            case 2:
            classItem = viewModel.dataSell.value[indexPath.row]
            default:
            classItem = viewModel.data.value[indexPath.row]
        }
        cell.configureWith(classItem: classItem) { image in
            DispatchQueue.main.async {
                if indexPath == tableView.indexPath(for: cell) {
                    cell.thumbnailView.image = image
                }
            }
        }
        return cell
    }
}

// MARK: - TableViewDelegate

extension CategoryDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(segmentControlIndex: segmentedControl.selectedSegmentIndex, at: indexPath.row)
    }
}
