//
//  ClassDetailViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/07.
//

import UIKit

protocol ClassDetailViewModelDelegate: AnyObject {
    func presentDisableAlert()
    func presentEnableAlert()
    func pushViewÇontroller(vc: UIViewController)
}

public class ClassDetailViewModel: ViewModel {
    private let storageManager = StorageManager.shared
    private let firestoreManager = FirestoreManager.shared
    private let firebaseAuthManager = FirebaseAuthManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared

    var classItem: ClassItem
    var checkChannel: [Channel] = []
    private var currentUser: User?
    weak var delegate: ClassDetailViewModelDelegate?

    let isStarButtonSelected: Observable<Bool> = Observable(false)
    let isClassItemOnSale: Observable<Bool> = Observable(true)
    let isNowFetchingImages: Observable<Bool> = Observable(true)
    let classItemImages: Observable<[UIImage]> = Observable([])
    let writer: Observable<User?> = Observable(nil)
    var isMyClassItem: Bool {
        return classItem.writer == currentUser?.id
    }

    init(classItem: ClassItem) {
        self.classItem = classItem
        getUserData()
        checkStar()
        fetchClassItemImages()
        userDefaultsManager.isUserDataChanged.bind { [weak self] isTrue in
            if isTrue {
                self?.getUserData()
                self?.userDefaultsManager.isUserDataChanged.value = false
            }
        }
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
              let _writer = writer.value else { return }
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
                        writer.value?.channels?.append(channel.id)
                    } else {
                        writer.value?.channels = [channel.id]
                    }
                    firestoreManager.uploadUser(user: currentUser!) { result in
                        switch result {
                            case .success(_):
                                print("업로드 성공")
                            case .failure(_):
                                print("업로드 실패")
                        }
                    }
                    firestoreManager.uploadUser(user: writer.value!) { result in
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
        firestoreManager.delete(classItem: classItem)
    }

    /// 수업 활성화/비활성화 메서드
    func toggleClassItem() {
        classItem.validity.toggle()
        isClassItemOnSale.value = classItem.validity
        firestoreManager.update(classItem: classItem) {}
    }

    /// 수업 이미지 패칭 메서드
    private func fetchClassItemImages() {
        isNowFetchingImages.value = true
        classItem.fetchedImages { [weak self] images in
            self?.isNowFetchingImages.value = false
            self?.classItemImages.value = images ?? []
        }
    }
    
    private func fetchClassItemWriter() {
        firestoreManager.readUser(uid: classItem.writer) { [weak self] result in
            switch result {
            case .success(let user):
                self?.writer.value = user
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
                self.writer.value = user
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
            isStarButtonSelected.value = true
        } else {
            print("nostared")
            isStarButtonSelected.value = false
        }
    }

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
