//
//  MainViewController.swift
//  ClassToday
//
//  Created by poohyhy on 2022/04/19.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    //MARK: - NavigationBar Components
    private lazy var leftTitle: UIButton = {
        let leftTitle = UIButton()
        leftTitle.setTitleColor(UIColor.black, for: .normal)
        leftTitle.titleLabel?.sizeToFit()
        leftTitle.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
        leftTitle.addTarget(self, action: #selector(didTapTitleLabel(_:)), for: .touchUpInside)
        return leftTitle
    }()

    private lazy var starItem: UIBarButtonItem = {
        let starItem = UIBarButtonItem.menuButton(self, action: #selector(didTapStarButton), image: Icon.star.image)
        return starItem
    }()

    private lazy var categoryItem: UIBarButtonItem = {
        let categoryItem = UIBarButtonItem.menuButton(self, action: #selector(didTapCategoryButton), image: Icon.category.image)
        return categoryItem
    }()

    private lazy var searchItem: UIBarButtonItem = {
        let searchItem = UIBarButtonItem.menuButton(self, action: #selector(didTapSearchButton), image: Icon.search.image)
        return searchItem
    }()

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftTitle)
        navigationItem.rightBarButtonItems = [starItem, searchItem, categoryItem]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    //MARK: - Main View의 UI Components
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
        label.isHidden = true
        label.textColor = UIColor.systemGray
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .mainColor
        refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
        return refreshControl
    }()

    // - MVVM
    private let viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        layout()
        bindViewModel()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    //MARK: - Methods
    private func bindViewModel() {
        /// 유저 정보 바인딩
        viewModel.currentUser.bind { [weak self] currentUser in
            if let _ = currentUser {
                self?.viewModel.fetchData()
            }
        }

        /// 지역명 패칭 진행중인지 바인딩
        viewModel.isNowLocationFetching.bind { [weak self] isFetching in
            if isFetching {
                self?.classItemTableView.refreshControl?.beginRefreshing()
            } else {
                self?.classItemTableView.refreshControl?.endRefreshing()
            }
        }

        /// 수업 아이템 패칭중인지 바인딩
        viewModel.isNowDataFetching.bind { [weak self] isFetching in
            if isFetching {
                self?.classItemTableView.refreshControl?.beginRefreshing()
                self?.nonDataAlertLabel.isHidden = true
            } else {
                self?.classItemTableView.refreshControl?.endRefreshing()
            }
        }

        /// 위치정보권한 유무 바인딩
        viewModel.isLocationAuthorizationAllowed.bind { [weak self] isAllowed in
            if !isAllowed {
                self?.nonAuthorizationAlertLabel.isHidden = false
                self?.present(UIAlertController.locationAlert(), animated: true) {
                    self?.refreshControl.endRefreshing()
                    self?.viewModel.checkLocationAuthorization()
                }
            } else {
                self?.nonAuthorizationAlertLabel.isHidden = true
            }
        }

        /// 지역명 바인딩
        viewModel.locationTitle.bind { [weak self] locationTitle in
            if let locationTitle = locationTitle {
                DispatchQueue.main.async {
                    self?.leftTitle.setTitle(locationTitle, for: .normal)
                    self?.leftTitle.frame.size = self?.leftTitle.titleLabel?.intrinsicContentSize ?? CGSize(width: 0, height: 0)
                }
            }
        }

        /// 수업아이템 바인딩
        viewModel.data.bind { [weak self] classItems in
            if classItems.isEmpty {
                self?.nonDataAlertLabel.isHidden = false
            }
            self?.classItemTableView.reloadData()
        }

        viewModel.classDetailViewController.bind { [weak self] viewController in
            if let viewController = viewController {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }

        viewModel.categoryListViewController.bind { [weak self] viewController in
            if let viewController = viewController {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

//MARK: - gesture delegate
extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - objc functions
private extension MainViewController {
    @objc func didTapTitleLabel(_ sender: UIButton) {
        let locationSettingViewController = LocationSettingViewController()
        navigationController?.pushViewController(locationSettingViewController, animated: true)
    }

    @objc func didChangedSegmentControlValue(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("모두")
            classItemTableView.reloadData()
        case 1:
            print("구매글")
            classItemTableView.reloadData()
        case 2:
            print("판매글")
            classItemTableView.reloadData()
        default:
            break
        }
    }

    @objc func beginRefresh() {
        print("beginRefresh!")
        viewModel.refreshClassItemList()
    }

    @objc func didTapStarButton() {
        let starViewController = StarViewController()
        navigationController?.pushViewController(starViewController, animated: true)
    }

    @objc func didTapCategoryButton() {
        viewModel.didTapCategoryButton()
    }

    @objc func didTapSearchButton() {
        let searchViewController = AppDIContainer().makeDIContainer().makeSearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}

private extension MainViewController {
    //MARK: - set autolayout
    func layout() {
        [
            segmentedControl,
            classItemTableView,
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

//MARK: - TableView datasource
extension MainViewController: UITableViewDataSource {
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
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(segmentControlIndex: segmentedControl.selectedSegmentIndex, at: indexPath.row)
    }
}
