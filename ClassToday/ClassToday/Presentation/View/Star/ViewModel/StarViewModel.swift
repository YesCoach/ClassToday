//
//  StarViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol StarViewModelInput {
    func refreshClassItemList()
    func fetchData()
    func didSelectItem(at index: Int)
}

protocol StarViewModelOutput {
    var isNowDataFetching: BehaviorRelay<Bool> { get }
    var data: BehaviorSubject<[ClassItem]> { get }
    var currentUser: BehaviorSubject<User?> { get }
    var classDetailViewController: BehaviorSubject<ClassDetailViewController?> { get }
}

protocol StarViewModel: StarViewModelInput, StarViewModelOutput { }

public class DefaultStarViewModel: StarViewModel {

    private let fetchUseCase: FetchClassItemUseCase
    private let disposeBag = DisposeBag()

    // MARK: - OUTPUT
    let isNowDataFetching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let data: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    let currentUser: BehaviorSubject<User?> = BehaviorSubject(value: nil)
    let classDetailViewController: BehaviorSubject<ClassDetailViewController?> = BehaviorSubject(value: nil)

    init(fetchUseCase: FetchClassItemUseCase) {
        self.fetchUseCase = fetchUseCase
        configureLocation()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUserData(_:)),
            name: NSNotification.Name("updateUserData"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 유저의 키워드 주소에 따른 기준 지역 구성
    private func configureLocation() {
        _ = User.getCurrentUserRx()
            .subscribe(
                onNext: { user in
                    self.currentUser.onNext(user)
                },
                onError: { error in
                    print("ERROR \(error)🌔")
                }
            )
            .disposed(by: disposeBag)
    }

    /// 유저 정보에 변경이 있으면, 새로 업데이트 진행
    @objc func updateUserData(_ notification: Notification) {
        configureLocation()
    }
}

// MARK: - INPUT
extension DefaultStarViewModel {
    func refreshClassItemList() {
        fetchData()
    }

    /// 즐겨찾기 수업 정보를 패칭하는 메서드
    func fetchData() {
        isNowDataFetching.accept(true)

        guard let currentUser = try? currentUser.value() else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.accept(false)
            return
        }

        // TODO: Rx Method 적용시 하나의 값만 반환되는 버그 발생
        fetchUseCase.executeRx(param: .fetchByStarlist(starlist: currentUser.stars))
            .map { (classItems) -> [ClassItem] in
                classItems.sorted { $0 > $1 }
            }
            .subscribe(onNext: { [weak self] data in
                self?.isNowDataFetching.accept(false)
                self?.data.onNext(data)
            })
            .disposed(by: disposeBag)
    }

    func didSelectItem(at index: Int) {
        if let classItem = try? data.value()[index] {
            classDetailViewController.onNext(
                AppDIContainer()
                    .makeDIContainer()
                    .makeClassDetailViewController(classItem: classItem)
            )
            classDetailViewController.onNext(nil)
        }
    }
}
