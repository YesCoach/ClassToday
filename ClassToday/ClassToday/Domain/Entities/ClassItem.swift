//
//  ClassItem.swift
//  ClassToday
//
//  Created by yc on 2022/03/29.
//

import UIKit
import CoreLocation
import RxSwift

enum ClassItemError: Error {
    case invalidImageURL
}

struct ClassItem: Codable, Equatable {
    var id: String = UUID().uuidString
    let name: String
    let date: Set<DayWeek>?
    let time: String?
    let place: String?
    let location: Location?
    let semiKeywordLocation: String?
    let keywordLocation: String?
    let price: String?
    let priceUnit: PriceUnit
    let description: String
    let images: [String]?
    let subjects: Set<Subject>?
    let targets: Set<Target>?
    let itemType: ClassItemType
    var validity: Bool
    var writer: String
    let createdTime: Date
    let modifiedTime: Date?

    // MARK: - RxSwift 메서드

    func thumbnailImageRx() -> Observable<UIImage> {
        return Observable.create { emitter in
            guard let imagesURL = images, let url = imagesURL.first else {
                emitter.onError(ClassItemError.invalidImageURL)
                return Disposables.create()
            }

            StorageManager.shared.downloadImage(urlString: url) { result in
                switch result {
                case .success(let image):
                    emitter.onNext(image)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func fetchedImagesRx() -> Observable<[UIImage]> {
        return Observable.create { emitter in
            var fetchedImages: [UIImage] = []
            let group = DispatchGroup()

            guard let imagesURL = images else {
                emitter.onNext([])
                emitter.onCompleted()
                return Disposables.create()
            }

            imagesURL.forEach { url in
                group.enter()
                StorageManager.shared.downloadImage(urlString: url) { result in
                    switch result {
                    case .success(let image):
                        fetchedImages.append(image)
                    case .failure(let error):
                        debugPrint(error)
                    }
                    group.leave()
                }
            }

            group.notify(queue: DispatchQueue.main) {
                emitter.onNext(fetchedImages)
                emitter.onCompleted()
            }

            return Disposables.create()
        }
    }

    /// 수업이 업로드 되고 경과된 시간을 계산하여, 문자열로 반환합니다.
    ///
    /// - form: " | @개월 전" [개월, 일, 시간, 분, 방금 전]
    func pastDateCalculate() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: self.createdTime, to: Date())
        var text = ""
        if let month = components.month, month != 0 {
            text = " | \(month)개월 전"
        } else if let day = components.day, day != 0 {
            text = " | \(day)일 전"
        } else if let hour = components.hour, hour != 0 {
            text = " | \(hour)시간 전"
        } else if let minute = components.minute, minute != 0 {
            text = " | \(minute)분 전"
        } else {
            text = " | 방금 전"
        }
        return text
    }
    
    static func > (lhd: Self, rhd: Self) -> Bool {
        return lhd.createdTime > rhd.createdTime
    }
}
