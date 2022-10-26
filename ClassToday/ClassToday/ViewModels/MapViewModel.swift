//
//  MapViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/26.
//

import Foundation
import SwiftUI

public class MapViewModel: LocationViewModel, FetchingViewModel {
    private let userDefaultsManager = UserDefaultsManager.shared
    private let locationManager = LocationManager.shared
    private let firestoreManager = FirestoreManager.shared
    private let naverMapAPIProvider = NaverMapAPIProvider()
    
    private let currentUser: User
    let currentKeyword: Observable<String?> = Observable(nil)
    let currentLocation: Observable<Location?> = Observable(nil)
    let categoryData: Observable<[CategoryItem]> = Observable([])
    let mapClassItemData: Observable<[ClassItem]> = Observable([])
    let listClassItemData: Observable<[ClassItem]> = Observable([])
    
    override init() {
        guard let user = userDefaultsManager.getUserData() else {
            fatalError()
        }
        currentUser = user
        super.init()
    }

    /// 위치정보권한 확인 및 허용 시 지역 패칭
    override func checkLocationAuthorization() {
        super.checkLocationAuthorization()
        if isLocationAuthorizationAllowed.value {
            getCurrentLocation()
        }
    }

    /// 전체 수업 아이템을 패칭합니다.
    func fetchData() {
        firestoreManager.fetch { [weak self] data in
            self?.mapClassItemData.value = data
        }
    }
    
    /// 지역 수업 아이템을 패칭합니다.
    func fetchKeywordData() {
        var localClassItemData: [ClassItem] = []
        mapClassItemData.value.forEach {
            if $0.keywordLocation == currentKeyword.value {
                localClassItemData.append($0)
            }
        }
        listClassItemData.value = localClassItemData.sorted { $0 > $1 }
    }
    
    /// 카테고리 수업 리스트를 패칭합니다.
    ///
    /// 기존 맵 수업 리스트를 카테고리 리스트로 대체
    func fetchCategoryData() {
        firestoreManager.categorySort(categories: categoryData.value
            .map{$0 as? Subject}
            .compactMap{$0}
            .map{$0.rawValue}
        ){ [weak self] data in
            self?.mapClassItemData.value = data
        }
    }
    
    /// 즐겨찾기 수업 리스트를 패칭합니다.
    ///
    /// 기존 맵 수업 리스트를 즐겨찾기 리스트로 대체
    func fetchStarData() {
        guard let list = currentUser.stars, list.isEmpty == false else {
            mapClassItemData.value = []
            return
        }
        firestoreManager.starSort(starList: list) { [weak self] data in
            self?.mapClassItemData.value = data
        }
    }

    /// 현재 기기 위치를 받아서 지역 키워드를 저장합니다.
    ///
    // TODO: 앱 실행 직후에 기기 위치 정보를 받아올 수 없음. -> Bind로 해결
    private func getCurrentLocation() {
        currentLocation.value = locationManager.getCurrentLocation()
        DispatchQueue.global().async { [weak self] in
            self?.naverMapAPIProvider.locationToKeyword(
                location: self?.currentLocation.value
            ) { result in
                switch result {
                case .success(let keyword):
                    self?.currentKeyword.value = keyword
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }

    // MARK: - Input
    /// 카테고리 선택시, 선택한 카테고리를 뷰 모델에 반영
    func selectCategory(categories: [Subject]) {
        categoryData.value = categories
    }
}
