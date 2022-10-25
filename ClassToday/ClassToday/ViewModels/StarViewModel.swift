//
//  StarViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/25.
//

import Foundation

public class StarViewModel: FetchingViewModel {
    private let firestoreManager = FirestoreManager.shared
    private let locationManager = LocationManager.shared
    private let provider = NaverMapAPIProvider()

    private var currentUser: User?
    private var group = DispatchGroup()

    var isNowDataFetching: Observable<Bool> = Observable(false)

    let data: Observable<[ClassItem]> = Observable([])

    init() {
        configureLocation()
    }

    /// 유저의 키워드 주소에 따른 기준 지역 구성
    private func configureLocation() {
        User.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                self.fetchData()
                
            case .failure(let error):
                print("ERROR \(error)🌔")
            }
        }
    }
    
    func fetchData() {
        isNowDataFetching.value = true
        guard let currentUser = currentUser else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.value = false
            return
        }
        firestoreManager.starSort(starList: currentUser.stars) { [weak self] data in
            self?.isNowDataFetching.value = false
            self?.data.value = data
        }
    }
    
}
