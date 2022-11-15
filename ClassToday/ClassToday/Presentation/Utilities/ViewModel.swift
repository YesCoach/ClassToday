//
//  ViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/25.
//

import Foundation

public class LocationViewModel {
    private let locationManager = LocationManager.shared
    var isLocationAuthorizationAllowed: Observable<Bool> = Observable(true)

    /// 위치정보 권한의 상태값을 체크합니다.
    func checkLocationAuthorization() {
        isLocationAuthorizationAllowed.value = LocationManager.shared.isLocationAuthorizationAllowed()
    }
}
