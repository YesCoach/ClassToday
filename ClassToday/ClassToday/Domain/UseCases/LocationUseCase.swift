//
//  LocationUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import Foundation

protocol LocationUseCase {
    /// 위치권한정보 메서드
    func requestAuthorization()
    /// 현재 기기의 위치를 반환합니다.
    func getCurrentLocation() -> Location?
    /// 위치정보권한이 활성화 되었는지 판단하는 메서드
    func isLocationAuthorizationAllowed() -> Bool
}

final class DefaultLocationUseCase: LocationUseCase {

    private let locationManager: LocationManager

    init(locationManager: LocationManager = .shared) {
        self.locationManager = locationManager
    }

    func requestAuthorization() {
        locationManager.requestAuthorization()
    }

    func getCurrentLocation() -> Location? {
        return locationManager.getCurrentLocation()
    }

    func isLocationAuthorizationAllowed() -> Bool {
        return locationManager.isLocationAuthorizationAllowed()
    }
}
