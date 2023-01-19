//
//  StarViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/25.
//

import Foundation

protocol StarViewModelInput {
    func refreshClassItemList()
    func fetchData()
    func didSelectItem(at index: Int)
}

protocol StarViewModelOutput {
    var isNowDataFetching: CustomObservable<Bool> { get }
    var data: CustomObservable<[ClassItem]> { get }
    var currentUser: CustomObservable<User?> { get }
    var classDetailViewController: CustomObservable<ClassDetailViewController?> { get }
}

protocol StarViewModel: StarViewModelInput, StarViewModelOutput { }

public class DefaultStarViewModel: StarViewModel {

    private let fetchUseCase: FetchClassItemUseCase

    // MARK: - OUTPUT
    let isNowDataFetching: CustomObservable<Bool> = CustomObservable(false)
    let data: CustomObservable<[ClassItem]> = CustomObservable([])
    let currentUser: CustomObservable<User?> = CustomObservable(nil)
    let classDetailViewController: CustomObservable<ClassDetailViewController?> = CustomObservable(nil)

    init(fetchUseCase: FetchClassItemUseCase) {
        self.fetchUseCase = fetchUseCase
        configureLocation()
        fetchData()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUserData(_:)),
                                               name: NSNotification.Name("updateUserData"),
                                               object: nil)
    }

    /// 유저의 키워드 주소에 따른 기준 지역 구성
    private func configureLocation() {
        User.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser.value = user
            case .failure(let error):
                print("ERROR \(error)🌔")
            }
        }
    }

    /// 유저 정보에 변경이 있으면, 새로 업데이트 진행
    @objc func updateUserData(_ notification: Notification) {
        configureLocation()
    }
}

// MARK: - INPUT
extension DefaultStarViewModel {
    /// 즐겨찾기 수업 정보를 패칭하는 메서드
    func fetchData() {
        isNowDataFetching.value = true
        guard let currentUser = currentUser.value else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.value = false
            return
        }
        fetchUseCase.excute(param: .fetchByStarlist(starlist: currentUser.stars)) { [weak self] data in
            self?.isNowDataFetching.value = false
            self?.data.value = data
        }
    }

    func refreshClassItemList() {
        fetchData()
    }

    func didSelectItem(at index: Int) {
        classDetailViewController.value = ClassDetailViewController(classItem: data.value[index])
    }
}
