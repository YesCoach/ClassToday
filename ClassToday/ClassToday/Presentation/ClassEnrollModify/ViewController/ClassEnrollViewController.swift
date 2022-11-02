//
//  ClassEnrollViewController.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/03.
//

import UIKit
import SnapKit
import Popover
import FirebaseFirestore
import FirebaseFirestoreSwift
import Moya

protocol ClassItemCellUpdateDelegate: AnyObject {
    func updatePriceUnit(with priceUnit: PriceUnit)
}

class ClassEnrollViewController: UIViewController {

    // MARK: - Views
    private lazy var customNavigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.setItems([customNavigationItem], animated: true)
        return navigationBar
    }()

    private lazy var customNavigationItem: UINavigationItem = {
        let item = UINavigationItem(title: "수업 \(viewModel.classItemType.rawValue) 등록하기")
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapBackButton(_:)))
        let rightButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(didTapEnrollButton(_:)))
        leftButton.tintColor = UIColor.mainColor
        rightButton.tintColor = UIColor.mainColor
        item.leftBarButtonItem = leftButton
        item.rightBarButtonItem = rightButton
        return item
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.selectionFollowsFocus = false
        tableView.refreshControl = refreshControl
        tableView.register(EnrollImageCell.self, forCellReuseIdentifier: EnrollImageCell.identifier)
        tableView.register(EnrollNameCell.self, forCellReuseIdentifier: EnrollNameCell.identifier)
        tableView.register(EnrollTimeCell.self, forCellReuseIdentifier: EnrollTimeCell.identifier)
        tableView.register(EnrollDateCell.self, forCellReuseIdentifier: EnrollDateCell.identifier)
        tableView.register(EnrollPlaceCell.self, forCellReuseIdentifier: EnrollPlaceCell.identifier)
        tableView.register(EnrollPriceCell.self, forCellReuseIdentifier: EnrollPriceCell.identifier)
        tableView.register(EnrollDescriptionCell.self, forCellReuseIdentifier: EnrollDescriptionCell.identifier)
        tableView.register(EnrollCategoryCell.self, forCellReuseIdentifier: EnrollCategoryCell.identifier)
        return tableView
    }()

    private lazy var popover: Popover = {
        let popover = Popover(options: nil, showHandler: nil, dismissHandler: nil)
        return popover
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .mainColor
        refreshControl.isHidden = true
        return refreshControl
    }()

    private lazy var alert: UIAlertController = {
        let alert = UIAlertController(title: "알림", message: "필수 항목을 입력해주세요", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }()

    // MARK: - Properties
    weak var delegate: ClassItemCellUpdateDelegate?
    private var viewModel:  ClassEnrollModifyViewModel

    // MARK: - Initialize
    init(classItemType: ClassItemType) {
        viewModel =  ClassEnrollModifyViewModel(classItemType: classItemType)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
        bindingViewModel()
    }

    // MARK: - Method
    private func configureUI() {
        configureNavigationBar()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(customNavigationBar.snp.bottom)
        }
        tableView.addSubview(refreshControl)
        refreshControl.snp.makeConstraints {
            $0.centerX.centerY.equalTo(view)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }

    private func configureNavigationBar() {
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }

    /// 단일 탭 제스처 등록
    private func configureGesture() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapMethod(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    private func bindingViewModel() {
        viewModel.isNowDataUploading.bind { [weak self] isTrue in
            DispatchQueue.main.async {
                if isTrue {
                    self?.refreshControl.isHidden = false
                    self?.refreshControl.beginRefreshing()
                } else {
                    self?.refreshControl.isHidden = true
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }

    // MARK: - Actions
    /// 탭 제스쳐가 들어가면, 수정모드를 종료한다
    @objc func myTapMethod(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @objc func didTapBackButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    /// 수업 등록 메서드
    @objc func didTapEnrollButton(_ button: UIBarButtonItem) {
        view.endEditing(true)
        viewModel.enrollClassItem()
    }
}

// MARK: - TableViewDataSource
extension ClassEnrollViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 7 ? CategoryType.allCases.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollImageCell.identifier, for: indexPath)
                    as? EnrollImageCell else { return UITableViewCell() }
            cell.delegate = self
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollNameCell.identifier, for: indexPath)
                    as? EnrollNameCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setUnderline()
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollTimeCell.identifier, for: indexPath)
                    as? EnrollTimeCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setUnderline()
            cell.configureWithItemType()
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollDateCell.identifier, for: indexPath)
                    as? EnrollDateCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setUnderline()
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollPlaceCell.identifier, for: indexPath)
                    as? EnrollPlaceCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setUnderline()
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollPriceCell.identifier, for: indexPath)
                    as? EnrollPriceCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setUnderline()
            delegate = cell
            return cell
        case 6:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollDescriptionCell.identifier, for: indexPath)
                    as? EnrollDescriptionCell else { return UITableViewCell() }
            cell.delegate = self
            return cell
        case 7:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollCategoryCell.identifier, for: indexPath)
                    as? EnrollCategoryCell else { return UITableViewCell() }
            cell.delegate = self
            cell.configureType(with: CategoryType.allCases[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - TableViewDelegate
extension ClassEnrollViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return view.frame.height * 0.2
        case 1, 2, 3, 4, 5:
            return view.frame.height * 0.08
        case 6:
            return view.frame.height * 0.3
        case 7:
            switch CategoryType.allCases[indexPath.row] {
            case .subject:
                let lines = Subject.count / 2 + Subject.count % 2
                let height = Int(ClassCategoryCollectionViewCell.height) * lines +
                ClassCategoryCollectionReusableView.height
                return CGFloat(height)
            case .target:
                let lines = Target.count / 2 + Target.count % 2
                let height = Int(ClassCategoryCollectionViewCell.height) * lines +
                ClassCategoryCollectionReusableView.height
                return CGFloat(height)
            }
        default:
            return CGFloat(0)
        }
    }
}

// MARK: - Keyboard 관련 로직
extension ClassEnrollViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    @objc func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
}

// MARK: - CellDelegate Extensions
extension ClassEnrollViewController: EnrollImageCellDelegate {
    func passData(imagesURL: [String]) {
        return
    }
    func passData(images: [UIImage]) {
        viewModel.classImages = images.isEmpty ? nil : images
    }
    func presentFromImageCell(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - EnrollNameCellDelegate
extension ClassEnrollViewController: EnrollNameCellDelegate {
    func passData(name: String?) {
        viewModel.className = name
    }
}

// MARK: - EnrollTimeCellDelegate
extension ClassEnrollViewController: EnrollTimeCellDelegate {
    func passData(time: String?) {
        viewModel.classTime = time
        view.endEditing(true)
    }
    func getClassItemType() -> ClassItemType {
        return viewModel.classItemType
    }
}

// MARK: - EnrollDateCellDelegate
extension ClassEnrollViewController: EnrollDateCellDelegate {
    func passData(date: Set<DayWeek>) {
        viewModel.classDate = date
    }
    func presentFromDateCell(_ viewController: UIViewController) {
        view.endEditing(true)
        self.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - EnrollPlaceCellDelegate
extension ClassEnrollViewController: EnrollPlaceCellDelegate {
    func passData(place: String?, location: Location?) {
        viewModel.classPlace = place
        viewModel.classLocation = location
    }
    
    func presentFromPlaceCell(viewController: UIViewController) {
        present(viewController, animated: true)
    }
}

// MARK: - EnrollPriceCellDelegate
extension ClassEnrollViewController: EnrollPriceCellDelegate {
    func showPopover(button: UIButton) {
        let rect = button.convert(button.bounds, to: self.view)
        let point = CGPoint(x: rect.midX, y: rect.midY)
        let view = PriceUnitTableView(
            frame: CGRect(x: 0, y: 0,
                          width: view.frame.width / 3,
                          height: PriceUnitTableViewCell.height * CGFloat(PriceUnit.allCases.count)))
        view.delegate = self
        popover.show(view, point: point)
    }
    func passData(price: String?) {
        viewModel.classPrice = price
    }
    func passData(priceUnit: PriceUnit) {
        viewModel.classPriceUnit = priceUnit
    }
}

// MARK: - EnrollDescriptionCellDelegate
extension ClassEnrollViewController: EnrollDescriptionCellDelegate {
    func passData(description: String?) {
        viewModel.classDescription = description
    }
}

// MARK: - EnrollCategoryCellDelegate
extension ClassEnrollViewController: EnrollCategoryCellDelegate {
    func passData(subjects: Set<Subject>) {
        viewModel.classSubject = subjects
    }
    func passData(targets: Set<Target>) {
        viewModel.classTarget = targets
    }
}

// MARK: - PriceUnitTableViewDelegate
extension ClassEnrollViewController: PriceUnitTableViewDelegate {
    func selectedPriceUnit(priceUnit: PriceUnit) {
        viewModel.classPriceUnit = priceUnit
        delegate?.updatePriceUnit(with: priceUnit)
        popover.dismiss()
    }
}

// MARK: - ClassEnrollModifyViewModelDelegate
extension ClassEnrollViewController: ClassEnrollModifyViewModelDelegate {
    func presentAlert() {
        present(alert, animated: true)
    }
    func dismissViewController() {
        dismiss(animated: true)
    }
}
