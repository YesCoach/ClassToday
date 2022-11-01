//
//  ClassEnrollModifyViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/01.
//

import UIKit

protocol ClassEnrollModifyViewModelDelegate {
    func presentAlert()
    func dismissViewController()
}

public class  ClassEnrollModifyViewModel: ViewModel {
    private let firestoreManager = FirestoreManager.shared
    private let storageManager = StorageManager.shared
    private let locationManager = LocationManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    private let provider = NaverMapAPIProvider()

    let classItemType: ClassItemType
    var delegate: ClassEnrollModifyViewModelDelegate?
    var isNowDataUploading: Observable<Bool> = Observable(false)
    var classImages: [UIImage]?
    var classImagesURL: [String]?
    var className: String?
    var classTime: String?
    var classDate: Set<DayWeek>?
    var classPlace: String?             // 도로명주소 값
    var classPrice: String?
    var classPriceUnit: PriceUnit = .perHour
    var classDescription: String?
    var classSubject: Set<Subject>?
    var classTarget: Set<Target>?
    var classLocation: Location?        // 위도, 경도 값
    var classSemiKeywordLocation: String?          // "@@시"
    var classKeywordLocation: String?   // 패칭 기준값, "@@구"

    // MARK: - For Modify View
    var classItem: ClassItem?

    /// 수업 등록시 ViewModel 생성자
    init(classItemType: ClassItemType = .buy) {
        self.classItemType = classItemType
    }
    
    /// 수업 수정시 ViewModel 생성자
    convenience init(classItem: ClassItem) {
        self.init(classItemType: classItem.itemType)
        self.classItem = classItem
        className = classItem.name
        classTime = classItem.time
        classDate = classItem.date
        classPlace = classItem.place
        classLocation = classItem.location
        classKeywordLocation = classItem.keywordLocation
        classSemiKeywordLocation = classItem.semiKeywordLocation
        classPrice = classItem.price
        classPriceUnit = classItem.priceUnit
        classDescription = classItem.description
        classSubject = classItem.subjects
        classTarget = classItem.targets
        classImagesURL = classItem.images
    }

    func enrollClassItem() {
        classImagesURL = []
        let group = DispatchGroup()

        /// 수업 등록시 필수 항목 체크
        guard let className = className, let classDescription = classDescription else {
            delegate?.presentAlert()
            return
        }

        /// 수업 판매 등록시
        if classItemType == .sell, classTime == nil {
            delegate?.presentAlert()
            return
        }

        if let classDate = classDate, classDate.isEmpty {
            self.classDate = nil
        }
        if let classSubject = classSubject, classSubject.isEmpty {
            self.classSubject = nil
        }
        if let classTarget = classTarget, classTarget.isEmpty {
            self.classTarget = nil
        }
        if let classImages = classImages {
            for image in classImages {
                group.enter()
                storageManager.upload(image: image) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.classImagesURL?.append(url)
                    case .failure(let error):
                        debugPrint(error)
                    }
                    group.leave()
                }
            }
        }
        /// location 추가
        if classLocation == nil {
            self.classLocation = locationManager.getCurrentLocation()
        }
        /// place (도로명주소) 추가
        if classPlace == nil {
            if let location = classLocation {
                group.enter()
                provider.locationToDetailAddress(location: location) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let address):
                        self.classPlace = address
                    case .failure(let error):
                        debugPrint(error)
                    }
                    group.leave()
                }
            } else {
                print("Enroll ClassItem but, No Location")
            }
        }
        /// keyword 주소 추가 (@@구)
        group.enter()
        provider.locationToKeyword(location: classLocation) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let keyword):
                self.classKeywordLocation = keyword
            case .failure(let error):
                debugPrint(error)
            }
            group.leave()
        }

        /// semiKeyword 주소 추가 (@@동)
        group.enter()
        provider.locationToSemiKeyword(location: classLocation) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let semiKeyword):
                self.classSemiKeywordLocation = semiKeyword
            case .failure(let error):
                debugPrint(error)
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.global()) { [weak self] in
            guard let self = self else { return }
            self.isNowDataUploading.value = true
            let classItem = ClassItem(name: className,
                                      date: self.classDate,
                                      time: self.classTime,
                                      place: self.classPlace,
                                      location: self.classLocation,
                                      semiKeywordLocation: self.classSemiKeywordLocation,
                                      keywordLocation: self.classKeywordLocation,
                                      price: self.classPrice,
                                      priceUnit: self.classPriceUnit,
                                      description: classDescription,
                                      images: self.classImagesURL,
                                      subjects: self.classSubject,
                                      targets: self.classTarget,
                                      itemType: self.classItemType,
                                      validity: true,
                                      writer: UserDefaultsManager.shared.isLogin()!,
                                      createdTime: Date(),
                                      modifiedTime: nil
            )
            self.firestoreManager.upload(classItem: classItem) { [weak self] in
                guard let self = self else { return }
                debugPrint("\(classItem) 등록")
                self.isNowDataUploading.value = false
                self.delegate?.dismissViewController()
            }
        }
    }
    
    func modifyClassItem(completion: @escaping (ClassItem)->()) {
        let group = DispatchGroup()
        guard let classItem = classItem else {
            return
        }
        /// 수업 등록시 필수 항목 체크
        guard let className = className, let classDescription = classDescription else {
            delegate?.presentAlert()
            return
        }
        /// 수업 판매 등록시
        if classItem.itemType == .sell, classTime == nil {
            delegate?.presentAlert()
            return
        }
        if let classDate = classDate, classDate.isEmpty {
            self.classDate = nil
        }
        if let classSubject = classSubject, classSubject.isEmpty {
            self.classSubject = nil
        }
        if let classTarget = classTarget, classTarget.isEmpty {
            self.classTarget = nil
        }
        /// 1. 삭제한 사진 Storage에서 삭제
        /// 2. 삭제하지 않은 사진 파악 -> Storage에 올리지 않기
        var existingImagesCount = 0
        classItem.images?.forEach({ url in
            if classImagesURL?.contains(url) == false {
                storageManager.deleteImage(urlString: url)
            } else {
                existingImagesCount += 1
            }
        })
        if let classImages = classImages {
            for index in existingImagesCount ..< classImages.count {
                group.enter()
                storageManager.upload(image: classImages[index]) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.classImagesURL?.append(url)
                    case .failure(let error):
                        debugPrint(error)
                    }
                    group.leave()
                }
            }
        }
        if classLocation == nil {
            self.classLocation = locationManager.getCurrentLocation()
            if let location = classLocation {
                group.enter()
                provider.locationToDetailAddress(location: location) { [weak self] result in
                    switch result {
                    case .success(let address):
                        self?.classPlace = address
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    }
                    group.leave()
                }
            }
        }
        if classLocation != classItem.location {
            /// keyword 주소 추가 (@@구)
            group.enter()
            provider.locationToKeyword(location: classLocation) { [weak self] result in
                switch result {
                case .success(let keyword):
                    self?.classKeywordLocation = keyword
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
                group.leave()
            }
            /// semiKeyword 주소 추가 (@@동)
            group.enter()
            provider.locationToSemiKeyword(location: classLocation) { [weak self] result in
                switch result {
                case .success(let semiKeyword):
                    self?.classSemiKeywordLocation = semiKeyword
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.isNowDataUploading.value = true
            let modifiedClassItem = ClassItem(id: classItem.id,
                                              name: className,
                                              date: self.classDate,
                                              time: self.classTime,
                                              place: self.classPlace,
                                              location: self.classLocation,
                                              semiKeywordLocation: self.classSemiKeywordLocation,
                                              keywordLocation: self.classKeywordLocation,
                                              price: self.classPrice,
                                              priceUnit: self.classPriceUnit,
                                              description: classDescription,
                                              images: self.classImagesURL,
                                              subjects: self.classSubject,
                                              targets: self.classTarget,
                                              itemType: classItem.itemType,
                                              validity: true,
                                              writer: UserDefaultsManager.shared.isLogin()!,
                                              createdTime: Date(),
                                              modifiedTime: nil)
            self.firestoreManager.update(classItem: modifiedClassItem) { [weak self] in
                guard let self = self else { return }
                self.isNowDataUploading.value = false
                self.delegate?.dismissViewController()
                debugPrint("\(modifiedClassItem) 수정")
                completion(modifiedClassItem)
            }
        }
    }
}
