//
//  MapSelectionViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/02.
//

import Foundation
import NMapsMap

class MapSelectionViewModel {
    private let moyaProvider = NaverMapAPIProvider()
    private let locationManager = LocationManager.shared

    let isSubmitButtonOn: Observable<Bool> = Observable(false)
    let placeName: Observable<String?> = Observable(nil)
    let selectedPosition: Observable<NMGLatLng?> = Observable(nil)
    let userPosition: Observable<NMGLatLng?> = Observable(nil)
    
    /// 현재 유저의 위치를 설정합니다.
    func setUserPosition() {
        guard let currentLocation = locationManager.getCurrentLocation() else { return }
        userPosition.value = NMGLatLng(lat: currentLocation.lat, lng: currentLocation.lon)
    }

    /// MapView의 선택 위치를 초기화합니다.
    func setPosition(with location: Location?) {
        guard let location = location else { return }
        selectedPosition.value = NMGLatLng(lat: location.lat, lng: location.lon)
    }
    
    /// MapView의 선택 위치를 초기화합니다.
    func setPosition(with nmgLatLng: NMGLatLng) {
        selectedPosition.value = nmgLatLng
    }

    /// MapView의 선택 위치 주소명을 저장합니다.
    func setPlaceName(with location: Location?) {
        guard let location = location else {
            placeName.value = nil
            isSubmitButtonOn.value = false
            return
        }
        moyaProvider.locationToDetailAddress(location: location) { [weak self] result in
            switch result {
            case .success(let address):
                self?.placeName.value = address
                self?.isSubmitButtonOn.value = true
            case .failure(let error):
                debugPrint(error.localizedDescription)
                return
            }
        }
    }

    /// 맵의 선택 위치를 현재 위치로 설정합니다.
    func setPositionToCurrent() {
        guard let currentLocation = locationManager.getCurrentLocation() else { return }
        selectedPosition.value = NMGLatLng(lat: currentLocation.lat, lng: currentLocation.lon)
    }

    /// 맵의 선택 위치를 Location 타입으로 변환합니다.
    func getSelectedLocation() -> Location? {
        guard let position = selectedPosition.value else { return nil }
        return Location(lat: position.lat, lon: position.lng)
    }
}
