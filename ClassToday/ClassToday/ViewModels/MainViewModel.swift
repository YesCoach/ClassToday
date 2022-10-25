//
//  MainViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/13.
//

import Foundation

enum LocationError: Error {
    case NonSavedLocation
}

// for test, set ViewModel Public
public class MainViewModel: FetchingViewModel {
    private let firestoreManager = FirestoreManager.shared
    private let locationManager = LocationManager.shared
    private let provider = NaverMapAPIProvider()
    
    private var currentUser: User?
    private var group = DispatchGroup()

    var isLocationAuthorizationAllowed: Observable<Bool> = Observable(true)
    var isNowLocationFetching: Observable<Bool> = Observable(false)
    var isNowDataFetching: Observable<Bool> = Observable(false)
    let locationTitle: Observable<String?> = Observable(nil)

    let data: Observable<[ClassItem]> = Observable([])
    let dataBuy: Observable<[ClassItem]> = Observable([])
    let dataSell: Observable<[ClassItem]> = Observable([])

    init() {
        requestLocationAuthorization()
        configureLocation()
    }
    /// 유저의 키워드 주소에 따른 기준 지역 구성
    ///
    ///  - 출력 형태: "@@시 @@구의 수업"
    private func configureLocation() {
        group.enter()
        isNowLocationFetching.value = true
        User.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                self.group.leave()
                self.isNowLocationFetching.value = false
                guard let location = user.detailLocation else {
                    // TODO: 위치 설정 얼럿 호출 해야됨
                    self.locationTitle.value = nil
                    return
                }
                self.locationTitle.value = "\(location)의 수업"
                self.fetchData()

            case .failure(let error):
                self.group.leave()
                self.isNowLocationFetching.value = false
                self.locationTitle.value = nil
                print("ERROR \(error)🌔")
            }
        }
    }

    /// 키워드 주소를 기준으로 수업 아이템을 패칭합니다.
    ///
    /// - 패칭 기준: User의 KeywordLocation 값 ("@@구")
    func fetchData() {
        isNowDataFetching.value = true
        _ = group.wait(timeout: .now() + 10)
        guard let currentUser = self.currentUser else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.value = false
            return
        }
        guard let keyword = currentUser.keywordLocation else {
            debugPrint("유저의 키워드 주소 설정 값이 없습니다. 주소 설정 먼저 해주세요😭")
            isNowDataFetching.value = false
            return
        }
        
        self.firestoreManager.fetch(keyword: keyword) { [weak self] data in
            self?.isNowDataFetching.value = false
            // 최신순 정렬
            self?.data.value = data.sorted { $0 > $1 }
            self?.dataBuy.value = data.filter { $0.itemType == ClassItemType.buy }.sorted { $0 > $1 }
            self?.dataSell.value = data.filter { $0.itemType == ClassItemType.sell }.sorted { $0 > $1 }
        }
    }

    /// 위치정보 권한의 상태값을 체크합니다.
    private func requestLocationAuthorization() {
        isLocationAuthorizationAllowed.value = locationManager.isLocationAuthorizationAllowed()
    }
}
