//
//  ClassItemViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/16.
//

import UIKit

// public for test
public class ClassItemViewModel {
    
    private let storageManager = StorageManager.shared
    private let locationManager = LocationManager.shared

    private let classItem: ClassItem
//    var classTitle: String
//    var semiKeywordLocation: String?
//    var classPrice: String?
//    var classPriceUnit: String
//    var classTime: String?
//    var classThumbnailImage: UIImage?

    init(classItem: ClassItem) {
//        classTitle = classItem.name
//        semiKeywordLocation = classItem.semiKeywordLocation)
//        classPrice = Observable(classItem.price)
//        classPriceUnit = Observable(classItem.priceUnit.description)
//        classTime = Observable(classItem.pastDateCalculate())
//        classItem.thumbnailImage { [weak self] image in
//            print("이미지다운로드 ON")
//            self?.classThumbnailImage.value = image
//        }
        self.classItem = classItem
    }

    /// 수업 가격에 원화 표기를 붙여서 반환합니다.
    func classPriceWithWon() -> String? {
        guard let price = classItem.price else {
            return "가격협의"
        }
        return price.formattedWithWon()
    }

    func classTitle() -> String {
        return classItem.name
    }

    func classSemiKeywordLocation() -> String? {
        return classItem.semiKeywordLocation
    }

    func classPriceUnit() -> String? {
        guard let _ = classItem.price else {
            return nil
        }
        return classItem.priceUnit.description
    }

    func classTime() -> String {
        return classItem.pastDateCalculate()
    }

    func classThumbnailImage(_ completion: @escaping (UIImage?)->()) {
        classItem.thumbnailImage(completion: completion)
    }
}
