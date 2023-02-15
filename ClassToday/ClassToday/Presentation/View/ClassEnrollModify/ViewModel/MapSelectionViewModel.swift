//
//  MapSelectionViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/02.
//

import Foundation
import NMapsMap
import RxSwift
import RxCocoa

protocol MapSelectionViewModelInput {
    func viewDidLoad()
    func configure(location: Location?)
    func setPlaceName(with position: NMGLatLng?)
    func didTapCurrentLocationButton()
    func didTapMapView(with latlng: NMGLatLng)
}

protocol MapSelectionViewModelOutput {
    var isSubmitButtonOn: BehaviorRelay<Bool> { get }
    var placeName: BehaviorSubject<String?> { get }
    var userPosition: BehaviorSubject<NMGLatLng?> { get }
    var selectedPosition: BehaviorSubject<NMGLatLng?> { get }
    var selectedPositionToLocation: Location? { get }
}

protocol MapSelectionViewModel: MapSelectionViewModelInput, MapSelectionViewModelOutput { }

final class DefaultMapSelectionViewModel: MapSelectionViewModel {

    private let addressTransferUseCase: AddressTransferUseCase
    private let locationUseCase: LocationUseCase
    private let disposeBag = DisposeBag()

    // MARK: - OUTPUT

    let isSubmitButtonOn: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let placeName: BehaviorSubject<String?> = BehaviorSubject(value: nil)
    let selectedPosition: BehaviorSubject<NMGLatLng?> = BehaviorSubject(value: nil)
    let userPosition: BehaviorSubject<NMGLatLng?> = BehaviorSubject(value: nil)
    var selectedPositionToLocation: Location? {
        get {
            guard let position = try? selectedPosition.value() else { return nil }
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
        userPosition.onNext(NMGLatLng(lat: currentLocation.lat, lng: currentLocation.lon))
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
        selectedPosition.onNext(NMGLatLng(lat: currentLocation.lat, lng: currentLocation.lon))
    }

    /// 수업 위치가 이미 있다면, 맵의 위치에 반영합니다.
    func configure(location: Location?) {
        guard let location = location else { return }
        selectedPosition.onNext(NMGLatLng(lat: location.lat, lng: location.lon))
    }

    /// MapView의 선택 위치 주소명을 저장합니다.
    func setPlaceName(with position: NMGLatLng?) {
        guard let position = position else {
            placeName.onNext(nil)
            isSubmitButtonOn.accept(false)
            return
        }
        let location = Location(lat: position.lat, lon: position.lng)
        addressTransferUseCase.executeRx(location: location, param: .detailAddress)
            .subscribe(
                onNext: { [weak self] address in
                    self?.placeName.onNext(address)
                    self?.isSubmitButtonOn.accept(true)
                },
                onError: { error in
                    debugPrint(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    /// 선택한 좌표 값을 맵뷰에 반영합니다.
    func didTapMapView(with latlng: NMGLatLng) {
        selectedPosition.onNext(latlng)
    }
}
