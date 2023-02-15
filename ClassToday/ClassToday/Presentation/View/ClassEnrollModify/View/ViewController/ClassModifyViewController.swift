//
//  ClassModifyViewController.swift
//  ClassToday
//
//  Created by 박태현 on 2022/05/04.
//

import UIKit
import SnapKit
import Popover
import RxSwift

protocol ClassImageUpdateDelegate: AnyObject {
    func passDeletedImageIndex() -> Int
}

protocol ClassUpdateDelegate: AnyObject {
    func update(with classItem: ClassItem)
}

class ClassModifyViewController: UIViewController {
    // MARK: - Views
    private lazy var customNavigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.setItems([customNavigationItem], animated: true)
        return navigationBar
    }()

    private lazy var customNavigationItem: UINavigationItem = {
        let item = UINavigationItem(title: "게시글 수정")
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapBackButton(_:)))
        let rightButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(didTapEnrollButton(_:)))
        item.leftBarButtonItem = leftButton
        item.rightBarButtonItem = rightButton
        return item
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EnrollImageCell.self, forCellReuseIdentifier: EnrollImageCell.identifier)
        tableView.register(EnrollNameCell.self, forCellReuseIdentifier: EnrollNameCell.identifier)
        tableView.register(EnrollTimeCell.self, forCellReuseIdentifier: EnrollTimeCell.identifier)
        tableView.register(EnrollDateCell.self, forCellReuseIdentifier: EnrollDateCell.identifier)
        tableView.register(EnrollPlaceCell.self, forCellReuseIdentifier: EnrollPlaceCell.identifier)
        tableView.register(EnrollPriceCell.self, forCellReuseIdentifier: EnrollPriceCell.identifier)
        tableView.register(EnrollDescriptionCell.self, forCellReuseIdentifier: EnrollDescriptionCell.identifier)
        tableView.register(EnrollCategoryCell.self, forCellReuseIdentifier: EnrollCategoryCell.identifier)
        tableView.separatorStyle = .none
        tableView.selectionFollowsFocus = false
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .mainColor
        refreshControl.isHidden = true
        return refreshControl
    }()

    private lazy var popover: Popover = {
        let popover = Popover(options: nil, showHandler: nil, dismissHandler: nil)
        return popover
    }()

    private lazy var alert: UIAlertController = {
        let alert = UIAlertController(title: "알림", message: "필수 항목을 입력해주세요", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }()

    // MARK: - Properties
    weak var delegate: ClassItemCellUpdateDelegate?
    weak var imageDelegate: ClassImageUpdateDelegate?
    weak var classUpdateDelegate: ClassUpdateDelegate?

    private var viewModel: ClassEnrollModifyViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    init(viewModel: ClassEnrollModifyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
        bindViewModel()
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

    private func configureGesture() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapMethod(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(singleTapGestureRecognizer)
    }

    private func bindViewModel() {
        viewModel.isNowDataUploading
            .asDriver()
            .drive { [weak self] isTrue in
                if isTrue {
                    self?.refreshControl.isHidden = false
                    self?.refreshControl.beginRefreshing()
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.refreshControl.isHidden = true
                    self?.refreshControl.endRefreshing()
                    self?.view.isUserInteractionEnabled = true
                }
            }
            .disposed(by: disposeBag)

        viewModel.finishedUpload
            .subscribe(onCompleted: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.occuredAlert
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.present(self.alert, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.modifiedClassItem
            .bind { [weak self] classItem in
                self?.classUpdateDelegate?.update(with: classItem)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc func myTapMethod(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func didTapBackButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    /// 수업 등록 메서드
    @objc func didTapEnrollButton(_ button: UIBarButtonItem) {
        view.endEditing(true)
        viewModel.modifyClassItem()
    }
}

// MARK: - TableViewDataSource

extension ClassModifyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 7 {
            return CategoryType.allCases.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let classItem = viewModel.classItem else { fatalError() }
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollImageCell.identifier, for: indexPath) as? EnrollImageCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureWith(imagesURL: classItem.images)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollNameCell.identifier, for: indexPath) as? EnrollNameCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setUnderline()
            cell.configureWith(name: classItem.name)
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollTimeCell.identifier, for: indexPath) as? EnrollTimeCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setUnderline()
            cell.configureWithItemType()
            cell.configureWith(time: classItem.time)
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollDateCell.identifier, for: indexPath) as? EnrollDateCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setUnderline()
            cell.configureWith(date: classItem.date)
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollPlaceCell.identifier, for: indexPath) as? EnrollPlaceCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setUnderline()
            cell.configureWith(place: classItem.place, location: classItem.location)
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollPriceCell.identifier, for: indexPath) as? EnrollPriceCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setUnderline()
            cell.configureWith(price: classItem.price, priceUnit: classItem.priceUnit)
            delegate = cell
            return cell
        case 6:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollDescriptionCell.identifier, for: indexPath) as? EnrollDescriptionCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureWith(description: classItem.description)
            return cell
        case 7:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnrollCategoryCell.identifier, for: indexPath) as? EnrollCategoryCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            let categoryType = CategoryType.allCases[indexPath.row]
            switch categoryType {
            case .subject:
                cell.configure(with: categoryType, selectedCategory: Array(classItem.subjects ?? []))
            case .target:
                cell.configure(with: categoryType, selectedCategory: Array(classItem.targets ?? []))
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - TableViewDelegate
extension ClassModifyViewController: UITableViewDelegate {
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
extension ClassModifyViewController {
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
// MARK: - EnrollImageCellDelegate
extension ClassModifyViewController: EnrollImageCellDelegate {
    func passData(imagesURL: [String]) {
        viewModel.inputImagesURL(imagesURL: imagesURL)
    }

    func passData(images: [UIImage]) {
        viewModel.inputImages(images: images)
    }

    func presentFromImageCell(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - EnrollNameCellDelegate
extension ClassModifyViewController: EnrollNameCellDelegate {
    func passData(name: String?) {
        viewModel.inputClassName(name: name)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - EnrollTimeCellDelegate
extension ClassModifyViewController: EnrollTimeCellDelegate {
    func passData(time: String?) {
        viewModel.inputTime(time: time)
    }

    func getClassItemType() -> ClassItemType {
        return viewModel.classItemType
    }
}

// MARK: - EnrollDateCellDelegate
extension ClassModifyViewController: EnrollDateCellDelegate {
    func passData(date: Set<DayWeek>) {
        viewModel.inputDate(date: date)
    }

    func presentFromDateCell(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - EnrollPlaceCellDelegate
extension ClassModifyViewController: EnrollPlaceCellDelegate {
    func presentFromPlaceCell(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
 
    func passData(place: String?, location: Location?) {
        viewModel.inputPlace(place: place, location: location)
    }
}

// MARK: - EnrollPriceCellDelegate
extension ClassModifyViewController: EnrollPriceCellDelegate {
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
        viewModel.inputPrice(price: price)
    }
}

// MARK: - EnrollDescriptionCellDelegate
extension ClassModifyViewController: EnrollDescriptionCellDelegate {
    func passData(description: String?) {
        viewModel.inputDescription(description: description)
    }
}

// MARK: - EnrollCategoryCellDelegate
extension ClassModifyViewController: EnrollCategoryCellDelegate {
    func passData(categoryType: CategoryType, categoryItems: [CategoryItem]) {
        viewModel.inputCategory(categoryType: categoryType, categoryItems: categoryItems)
    }
}

// MARK: - PriceUnitTableViewDelegate
extension ClassModifyViewController: PriceUnitTableViewDelegate {
    func selectedPriceUnit(priceUnit: PriceUnit) {
        viewModel.inputPriceUnit(priceUnit: priceUnit)
        delegate?.updatePriceUnit(with: priceUnit)
        popover.dismiss()
    }
}
