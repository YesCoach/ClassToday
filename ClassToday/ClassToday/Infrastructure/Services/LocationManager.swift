//
//  LocationManager.swift
//  ClassToday
//
//  Created by 박태현 on 2022/06/01.
//

import UIKit
import CoreLocation

enum LocationManagerError: Error {
    case invalidLocation
    case emptyPlacemark
    case emptyPlacemarkLocality
    case emptyPlacemarkSubLocality
    case emptyLocationValue
}

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation()
    func didUpdateAuthorization()
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    weak var delegate: LocationManagerDelegate?

    private override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }

    /// 위치권한정보 메서드
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    /// 현재 기기의 위치를 반환합니다.
    func getCurrentLocation() -> Location? {
        guard let currentLocation = currentLocation else {
            return nil
        }
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        return Location(lat: lat, lon: lon)
    }

    /// 위치정보권한이 활성화 되었는지 판단하는 메서드
    func isLocationAuthorizationAllowed() -> Bool {
        return [CLAuthorizationStatus.authorizedAlways, .authorizedWhenInUse, .notDetermined].contains(locationManager.authorizationStatus)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.didUpdateAuthorization()
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("권한없음")
        default:
            print("알수없음")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        currentLocation = location
        manager.stopUpdatingLocation()
        delegate?.didUpdateLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }
}
