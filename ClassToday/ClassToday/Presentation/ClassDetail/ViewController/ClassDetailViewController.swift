//
//  ClassDetailViewController.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/08.
//

import UIKit

class ClassDetailViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DetailImageCell.self, forCellReuseIdentifier: DetailImageCell.identifier)
        tableView.register(DetailContentCell.self, forCellReuseIdentifier: DetailContentCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    private lazy var navigationBar: DetailCustomNavigationBar = {
        let navigationBar = DetailCustomNavigationBar(isImages: true)
        navigationBar.setupButton(with: classItem.writer.name)
        navigationBar.delegate = self
        return navigationBar
    }()
    private lazy var matchingButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapMatchingButton(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 15
        return button
    }()

    // MARK: - Properties

    private var classItem: ClassItem
    private let storageManager = StorageManager.shared
    private let fireStoreManager = FirestoreManager.shared

    // MARK: - Initialize

    init(classItem: ClassItem) {
        self.classItem = classItem
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        blackBackNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        self.hidesBottomBarWhenPushed = false
    }

    override func viewDidAppear(_ animated: Bool) {
    }
    // MARK: - Method

    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        tableView.addSubview(matchingButton)

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalToSuperview()
        }

        matchingButton.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.width.equalTo(view).multipliedBy(0.5)
        }

        if classItem.validity {
            setButtonOnSale()
        } else {
            setButtonOffSale()
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

    // MARK: - Actions

    @objc func didTapMatchingButton(_ button: UIButton) {
        debugPrint(#function)
    }
}

// MARK: - TableViewDataSource

extension ClassDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
            classItem.fetchedImages { images in
                cell.configureWith(images: images)
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailContentCell.identifier, for: indexPath) as? DetailContentCell else {
                return UITableViewCell()
            }
            cell.configureWith(classItem: classItem)
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
        present(ClassModifyViewController(classItem: classItem), animated: true, completion: nil)
    }
    func pushAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
    func deleteClassItem() {
        fireStoreManager.delete(classItem: classItem)
        navigationController?.popViewController(animated: true)
    }
    func toggleClassItem() {
        classItem.validity.toggle()
        if classItem.validity {
            setButtonOnSale()
        } else {
            setButtonOffSale()
        }
        fireStoreManager.update(classItem: classItem)
    }
    func classItemValidity() -> Bool {
        return classItem.validity
    }
}

// MARK: - Extension for Button
extension ClassDetailViewController {
    func setButtonOnSale() {
        matchingButton.setTitle(classItem.writer == MockData.mockUser ? "채팅 목록" : "신청하기", for: .normal)
        matchingButton.backgroundColor = .mainColor
        matchingButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    func setButtonOffSale() {
        matchingButton.setTitle("종료된 수업입니다", for: .normal)
        matchingButton.backgroundColor = .systemGray
        matchingButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
}
