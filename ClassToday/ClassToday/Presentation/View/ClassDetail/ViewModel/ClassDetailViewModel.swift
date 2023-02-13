//
//  ClassDetailViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/07.
//

import UIKit
import RxSwift
import RxCocoa

protocol ClassDetailViewModelDelegate: AnyObject {
    func presentDisableAlert()
    func presentEnableAlert()
    func pushViewÇontroller(vc: UIViewController)
}

protocol ClassDetailViewModelInput {
    func checkIsChannelAlreadyMade()
    func matchingUsers()
    func deleteClassItem()
    func toggleClassItem()
    func addStar()
    func deleteStar()
}

protocol ClassDetailViewModelOutput {
    var isStarButtonSelected: BehaviorRelay<Bool> { get }
    var isClassItemOnSale: BehaviorRelay<Bool> { get }
    var isNowFetchingImages: BehaviorRelay<Bool> { get }
    var isMyClassItem: Bool { get }
    var classItemImages: BehaviorSubject<[UIImage]> { get }
    var writer: BehaviorSubject<User?> { get }
    var classItem: ClassItem { get }
}

protocol ClassDetailViewModel: ClassDetailViewModelInput, ClassDetailViewModelOutput {
    var delegate: ClassDetailViewModelDelegate? { get set }
}

final class DefaultClassDetailViewModel: ClassDetailViewModel {

    private let deleteClassItemUseCase: DeleteClassItemUseCase
    private let firestoreManager: FirestoreManager
    private let userDefaultsManager: UserDefaultsManager

    var classItem: ClassItem
    var checkChannel: [Channel] = []
    private var currentUser: User?
    weak var delegate: ClassDetailViewModelDelegate?

    // MARK: - Output
    let isStarButtonSelected: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isClassItemOnSale: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let isNowFetchingImages: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let classItemImages: BehaviorSubject<[UIImage]> = BehaviorSubject(value: [])
    let writer: BehaviorSubject<User?> = BehaviorSubject(value: nil)
    var isMyClassItem: Bool {
        return classItem.writer == currentUser?.id
    }

    init(
        classItem: ClassItem,
        deleteClassItemUseCase: DeleteClassItemUseCase,
        firestoreManager: FirestoreManager,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.deleteClassItemUseCase = deleteClassItemUseCase
        self.classItem = classItem
        self.firestoreManager = firestoreManager
        self.userDefaultsManager = userDefaultsManager
        isClassItemOnSale.accept(classItem.validity)
        getUserData()
        checkStar()
        fetchClassItemImages()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUserData(_:)),
                                               name: NSNotification.Name("updateUserData"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func checkIsChannelAlreadyMade() {
        switch classItem.itemType {
            case .buy:
                firestoreManager.checkChannel(sellerID: UserDefaultsManager.shared.isLogin()!, buyerID: classItem.writer, classItemID: classItem.id) { [weak self] data in
                    guard let self = self else { return }
                    self.checkChannel = data
                }
            case .sell:
                firestoreManager.checkChannel(sellerID: classItem.writer, buyerID: UserDefaultsManager.shared.isLogin()!, classItemID: classItem.id) { [weak self] data in
                    guard let self = self else { return }
                    self.checkChannel = data
                }
        }
        print(checkChannel.count)
    }

    /// 매치를 진행하는 메서드
    func matchingUsers() {
        guard let _currentUser = currentUser,
              var _writer = try? writer.value() else { return }
        if classItem.validity == true {
            if classItem.writer == _currentUser.id {
                delegate?.presentDisableAlert()
            } else {
                if checkChannel.isEmpty {
                    let channel: Channel
                    switch classItem.itemType {
                        case .buy:
                            channel = Channel(sellerID: _currentUser.id, buyerID: classItem.writer, classItem: classItem)
                        case .sell:
                            channel = Channel(sellerID: classItem.writer, buyerID: _currentUser.id, classItem: classItem)
                    }
                    if let _ = _currentUser.channels {
                        currentUser?.channels?.append(channel.id)
                    } else {
                        currentUser?.channels = [channel.id]
                    }
                    if let _ = _writer.channels {
                        _writer.channels?.append(channel.id)
                        writer.onNext(_writer)
                    } else {
                        _writer.channels = [channel.id]
                        writer.onNext(_writer)
                    }
                    firestoreManager.uploadUser(user: currentUser!) { result in
                        switch result {
                            case .success(_):
                                print("업로드 성공")
                            case .failure(_):
                                print("업로드 실패")
                        }
                    }
                    firestoreManager.uploadUser(user: _writer) { result in
                        switch result {
                            case .success(_):
                                print("업로드 성공2")
                            case .failure(_):
                                print("업로드 실패2")
                        }
                    }
                    firestoreManager.uploadChannel(channel: channel)
                    let viewcontroller = ChatViewController(channel: channel)
                    delegate?.pushViewÇontroller(vc: viewcontroller)
                } else {
                    let channel = checkChannel[0]
                    let viewController = ChatViewController(channel: channel)
                    delegate?.pushViewÇontroller(vc: viewController)
                }
            }
        } else {
            if isMyClassItem {
                delegate?.presentEnableAlert()
            }
        }
    }

    /// 수업 아이템 삭제 메서드
    func deleteClassItem() {
        firestoreManager.delete(classItem: classItem) {}
    }

    /// 수업 활성화/비활성화 메서드
    func toggleClassItem() {
        classItem.validity.toggle()
        isClassItemOnSale.accept(classItem.validity)
        firestoreManager.update(classItem: classItem) {}
    }

    /// 수업 이미지 패칭 메서드
    private func fetchClassItemImages() {
        isNowFetchingImages.accept(true)
        classItem.fetchedImages { [weak self] images in
            self?.isNowFetchingImages.accept(false)
            self?.classItemImages.onNext(images ?? [])
        }
    }
    
    private func fetchClassItemWriter() {
        firestoreManager.readUser(uid: classItem.writer) { [weak self] result in
            switch result {
            case .success(let user):
                self?.writer.onNext(user)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }

    /// 현재 유저 정보와 작성자 정보를 불러오는 메서드
    private func getUserData() {
        User.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                self.checkStar()
            case .failure(let error):
                print("ERROR \(error)🌔")
            }
        }
        firestoreManager.readUser(uid: classItem.writer) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let user):
                self.writer.onNext(user)
                case .failure(let error):
                    print(error)
            }
        }
    }

    /// 즐겨찾기 여부 반영
    private func checkStar() {
        guard let starList: [String] = currentUser?.stars else { return }
        if starList.contains(classItem.id) {
            print("isalreadystared")
            isStarButtonSelected.accept(true)
        } else {
            print("nostared")
            isStarButtonSelected.accept(false)
        }
    }

    /// 유저 정보에 변경이 있으면, 새로 업데이트 진행
    @objc func updateUserData(_ notification: Notification) {
        getUserData()
    }

    // MARK: - 즐겨찾기 관련 메서드
    /// 즐겨찾기 추가 메서드
    func addStar() {
        currentUser?.stars?.append(classItem.id)
        firestoreManager.uploadUser(user: currentUser!) { result in
            switch result {
                case .success(_):
                    print("업로드 성공")
                case .failure(_):
                    print("업로드 실패")
            }
        }
    }

    /// 즐겨찾기 삭제 메서드
    func deleteStar() {
        if let index = currentUser?.stars?.firstIndex(of: classItem.id) {
            currentUser?.stars?.remove(at: index)
        }
        firestoreManager.uploadUser(user: currentUser!) { result in
            switch result {
                case .success(_):
                    print("업로드 성공")
                case .failure(_):
                    print("업로드 실패")
            }
        }
    }
}
