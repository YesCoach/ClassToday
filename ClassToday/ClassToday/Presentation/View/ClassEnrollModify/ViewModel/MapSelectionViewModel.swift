//
//  MapSelectionViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/02.
//

import Foundation
import NMapsMap

protocol MapSelectionViewModelInput {
    func viewDidLoad()
    func configure(location: Location?)
    func setPlaceName(with position: NMGLatLng?)
    func didTapCurrentLocationButton()
    func didTapMapView(with latlng: NMGLatLng)
}

protocol MapSelectionViewModelOutput {
    var isSubmitButtonOn: CustomObservable<Bool> { get }
    var placeName: CustomObservable<String?> { get }
    var userPosition: CustomObservable<NMGLatLng?> { get }
    var selectedPosition: CustomObservable<NMGLatLng?> { get }
    var selectedPositionToLocation: Location? { get }
}

protocol MapSelectionViewModel: MapSelectionViewModelInput, MapSelectionViewModelOutput { }

final class DefaultMapSelectionViewModel: MapSelectionViewModel {

    private let addressTransferUseCase: AddressTransferUseCase
    private let locationUseCase: LocationUseCase

    // MARK: - OUTPUT
    let isSubmitButtonOn: CustomObservable<Bool> = CustomObservable(false)
    let placeName: CustomObservable<String?> = CustomObservable(nil)
    let selectedPosition: CustomObservable<NMGLatLng?> = CustomObservable(nil)
    let userPosition: CustomObservable<NMGLatLng?> = CustomObservable(nil)
    var selectedPositionToLocation: Location? {
        get {
            guard let position = selectedPosition.value else { return nil }
            return Location(lat: position.lat, lon: position.lng)
        }
    }

    // MARK: - Init
    init(addressTransferUseCase: AddressTransferUseCase,
         locationUseCase: LocationUseCase) {
        self.addressTransferUseCase = addressTransferUseCase
        self.locationUseCase = locationUseCase
    }

    /// 현재 유저의 위치를 맵뷰에 반영합니다.
    private func setUserPosition() {
        guard let currentLocation = locationUseCase.getCurrentLocation() else { return }
        userPosition.value = NMGLatLng(lat: currentLocation.lat, lng: currentLocation.lon)
    }
}

// MARK: - Input
extension DefaultMapSelectionViewModel {
    func viewDidLoad() {
        setUserPosition()
    }

    /// 맵의 선택 위치를 현재 위치로 설정합니다.
    func didTapCurrentLocationButton() {
        guard let currentLocation = locationUseCase.getCurrentLocation() else { return }
        selectedPosition.value = NMGLatLng(lat: currentLocation.lat, lng: currentLocation.lon)
    }

    /// 수업 위치가 이미 있다면, 맵의 위치에 반영합니다.
    func configure(location: Location?) {
        guard let location = location else { return }
        selectedPosition.value = NMGLatLng(lat: location.lat, lng: location.lon)
    }

    /// MapView의 선택 위치 주소명을 저장합니다.
    func setPlaceName(with position: NMGLatLng?) {
        guard let position = position else {
            placeName.value = nil
            isSubmitButtonOn.value = false
            return
        }
        let location = Location(lat: position.lat, lon: position.lng)
        addressTransferUseCase.execute(location: location, param: .detailAddress) { [weak self] result in
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

    /// 선택한 좌표 값을 맵뷰에 반영합니다.
    func didTapMapView(with latlng: NMGLatLng) {
        selectedPosition.value = latlng
    }
}
