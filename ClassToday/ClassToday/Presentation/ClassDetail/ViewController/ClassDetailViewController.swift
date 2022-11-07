//
//  ClassDetailViewController.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/08.
//

import UIKit
import SwiftUI


class ClassDetailViewController: UIViewController {
    
    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DetailImageCell.self, forCellReuseIdentifier: DetailImageCell.identifier)
        tableView.register(DetailUserCell.self, forCellReuseIdentifier: DetailUserCell.identifier)
        tableView.register(DetailContentCell.self, forCellReuseIdentifier: DetailContentCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    private lazy var navigationBar: DetailCustomNavigationBar = {
        let navigationBar = DetailCustomNavigationBar(isImages: true)
        navigationBar.setupButton(with: viewModel.classItem.writer)
        navigationBar.delegate = self
        return navigationBar
    }()
    private lazy var matchingButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapMatchingButton(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 20
        return button
    }()

    private lazy var disableAlertController: UIAlertController = {
        let alert = UIAlertController(title: "모집을 종료하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.view?.tintColor = .mainColor
        let closeAction = UIAlertAction(title: "예", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.toggleClassItem()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        cancelAction.titleTextColor = .red
        [
            closeAction,
            cancelAction
        ].forEach { alert.addAction($0) }
        return alert
    }()

    private lazy var enableAlertController: UIAlertController = {
        let alert = UIAlertController(title: "모집을 재개할까요?", message: nil, preferredStyle: .alert)
        alert.view?.tintColor = .mainColor
        let closeAction = UIAlertAction(title: "예", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.toggleClassItem()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        cancelAction.titleTextColor = .red
        [
            closeAction,
            cancelAction
        ].forEach { alert.addAction($0) }
        return alert
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityIndicator.color = UIColor.mainColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.stopAnimating()
        return activityIndicator
    }()

    // MARK: - Properties
    var delegate: ClassUpdateDelegate?
    private var viewModel: ClassDetailViewModel

    // MARK: - Initialize
    init(classItem: ClassItem) {
        viewModel = ClassDetailViewModel(classItem: classItem)
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("------------------------------")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindingViewModel()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.checkIsChannelAlreadyMade()
        navigationController?.navigationBar.isHidden = true
        blackBackNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barStyle = .default
    }

    // MARK: - Method
    private func setUpUI() {
        view.backgroundColor = .white
        [tableView, navigationBar].forEach {view.addSubview($0)}
        tableView.addSubview(matchingButton)
        tableView.addSubview(activityIndicator)
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints {
            $0.center.equalTo(view)
        }
        matchingButton.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.width.equalTo(view).multipliedBy(0.5)
        }
    }

    private func whiteBackNavigationBar() {
        navigationBar.gradientLayer.backgroundColor = UIColor.white.cgColor
        navigationBar.gradientLayer.colors = [UIColor.white.cgColor]
        [navigationBar.backButton, navigationBar.starButton, navigationBar.rightButton].forEach {
            $0.tintColor = .mainColor
        }
        navigationBar.lineView.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }

    private func blackBackNavigationBar() {
        navigationBar.gradientLayer.backgroundColor = UIColor.clear.cgColor
        navigationBar.gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        [navigationBar.backButton, navigationBar.starButton, navigationBar.rightButton].forEach {
            $0.tintColor = .white
        }
        navigationBar.lineView.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }

    private func bindingViewModel() {
        viewModel.isNowFetchingImages.bind { [weak self] isTrue in
            DispatchQueue.main.async {
                isTrue ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
        }
        viewModel.isClassItemOnSale.bind { [weak self] isTrue in
            isTrue ? self?.setButtonOnSale() : self?.setButtonOffSale()
        }
        viewModel.isStarButtonSelected.bind { [weak self] isTrue in
            self?.navigationBar.starButton.isSelected = isTrue
        }
    }
    // MARK: - Actions
    @objc func didTapMatchingButton(_ button: UIButton) {
        viewModel.matchingUsers()
    }
}

// MARK: - TableViewDataSource
extension ClassDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailImageCell.identifier, for: indexPath) as? DetailImageCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            viewModel.classItemImages.bind { images in
                cell.configureWith(images: images)
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailUserCell.identifier, for: indexPath) as? DetailUserCell else {
                return UITableViewCell()
            }
            viewModel.writer.bind { [weak self] user in
                if let user = user {
                    cell.configure(with: user) {
                        self?.navigationController?.pushViewController(ProfileDetailViewController(user: $0), animated: true)
                    }
                }
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailContentCell.identifier, for: indexPath) as? DetailContentCell else {
                return UITableViewCell()
            }
            cell.configureWith(classItem: viewModel.classItem)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - TableViewDelegate
extension ClassDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return view.frame.height * 0.4
        case 1:
            return 96
        case 2:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }

    // 스크롤에 따른 네비게이션 바 전환
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = tableView.contentOffset.y
        if contentOffsetY > view.frame.height * 0.3 {
            whiteBackNavigationBar()
        } else {
            blackBackNavigationBar()
        }
    }
}

// MARK: - CellDelegate
extension ClassDetailViewController: DetailImageCellDelegate {
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}

// MARK: - NavigationBarDelegate
extension ClassDetailViewController: DetailCustomNavigationBarDelegate {
    func goBackPage() {
        navigationController?.popViewController(animated: true)
    }
 
    func pushEditPage() {
        let modifyViewController = ClassModifyViewController(classItem: viewModel.classItem)
        modifyViewController.classUpdateDelegate = self
        present(modifyViewController, animated: true, completion: nil)
    }

    func pushAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }

    func deleteClassItem() {
        viewModel.deleteClassItem()
        navigationController?.popViewController(animated: true)
    }

    func toggleClassItem() {
        viewModel.toggleClassItem()
    }

    func addStar() {
        viewModel.addStar()
    }

    func deleteStar() {
        viewModel.deleteStar()
    }
}

// MARK: - ClassUpdateDelegate
extension ClassDetailViewController: ClassUpdateDelegate {
    func update(with classItem: ClassItem) {
        viewModel.classItem = classItem
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}

// MARK: - ClassDetailViewModelDelegate
extension ClassDetailViewController: ClassDetailViewModelDelegate {
    func presentDisableAlert() {
        present(disableAlertController, animated: true)
    }
    func presentEnableAlert() {
        present(enableAlertController, animated: true)
    }
    func pushViewÇontroller(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Extension for Button
extension ClassDetailViewController {
    func setButtonOnSale() {
        matchingButton.setTitle(viewModel.isMyClassItem ? "비활성화" : "신청하기", for: .normal)
        matchingButton.backgroundColor = .mainColor
        matchingButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    func setButtonOffSale() {
        matchingButton.setTitle("종료된 수업입니다", for: .normal)
        matchingButton.backgroundColor = .systemGray
        matchingButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
}
