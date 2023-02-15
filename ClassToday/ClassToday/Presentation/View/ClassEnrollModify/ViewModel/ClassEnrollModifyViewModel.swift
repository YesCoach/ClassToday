//
//  ClassEnrollModifyViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/01.
//

import UIKit
import RxSwift
import RxCocoa

protocol ClassEnrollModifyViewModelInput {
    func inputImages(images: [UIImage])
    func inputImagesURL(imagesURL: [String])
    func inputClassName(name: String?)
    func inputTime(time: String?)
    func inputDate(date: Set<DayWeek>)
    func inputPlace(place: String?, location: Location?)
    func inputPrice(price: String?)
    func inputPriceUnit(priceUnit: PriceUnit)
    func inputDescription(description: String?)
    func inputCategory(categoryType: CategoryType, categoryItems: [CategoryItem])
    func enrollClassItem()
    func modifyClassItem()
}

protocol ClassEnrollModifyViewModelOutput {
    var isNowDataUploading: BehaviorRelay<Bool> { get }
    var finishedUpload: BehaviorSubject<Void> { get }
    var occuredAlert: BehaviorSubject<Void> { get }
    var classItemType: ClassItemType { get }
    var classItem: ClassItem? { get }
    var modifiedClassItem: PublishSubject<ClassItem> { get}
}

protocol ClassEnrollModifyViewModel: ClassEnrollModifyViewModelInput, ClassEnrollModifyViewModelOutput { }

public class DefaultClassEnrollModifyViewModel: ClassEnrollModifyViewModel {

    private let uploadClassItemUseCase: UploadClassItemUseCase
    private let imageUseCase: ImageUseCase
    private let locationUseCase: LocationUseCase
    private let addressTransferUseCase: AddressTransferUseCase
    private let disposeBag = DisposeBag()

    // MARK: - Output
    let isNowDataUploading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let finishedUpload: BehaviorSubject<Void> = BehaviorSubject(value: ())
    let occuredAlert: BehaviorSubject<Void> = BehaviorSubject(value: ())

    let modifiedClassItem: PublishSubject<ClassItem> = PublishSubject<ClassItem>()

    // MARK: - ClassItem Contents
    let classItemType: ClassItemType
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
    init(uploadClassItemUseCase: UploadClassItemUseCase,
         imageUseCase: ImageUseCase,
         locationUseCase: LocationUseCase,
         addressTransferUseCase: AddressTransferUseCase,
         classItemType: ClassItemType) {
        self.uploadClassItemUseCase = uploadClassItemUseCase
        self.imageUseCase = imageUseCase
        self.locationUseCase = locationUseCase
        self.addressTransferUseCase = addressTransferUseCase
        self.classItemType = classItemType
    }

    /// 수업 수정시 ViewModel 생성자
    convenience init(uploadClassItemUseCase: UploadClassItemUseCase,
                     imageUseCase: ImageUseCase,
                     locationUseCase: LocationUseCase,
                     addressTransferUseCase: AddressTransferUseCase,
                     classItem: ClassItem) {
        self.init(uploadClassItemUseCase: uploadClassItemUseCase,
                  imageUseCase: imageUseCase,
                  locationUseCase: locationUseCase,
                  addressTransferUseCase: addressTransferUseCase,
                  classItemType: classItem.itemType)
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

    // MARK: - Enroll ClassItem
    func enrollClassItem() {
        isNowDataUploading.accept(true)

        classImagesURL = []
        let group = DispatchGroup()

        /// 수업 등록시 필수 항목 체크
        guard let className = className, let classDescription = classDescription else {
            isNowDataUploading.accept(false)
            occuredAlert.onNext(())
            return
        }

        /// 수업 판매 등록시
        if classItemType == .sell, classTime == nil {
            isNowDataUploading.accept(false)
            occuredAlert.onNext(())
            return
        }

        if let classImages = classImages {
            for image in classImages {
                group.enter()
                imageUseCase.upload(image: image) { [weak self] result in
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
            self.classLocation = locationUseCase.getCurrentLocation()
        }

        guard let classLocation = classLocation else {
            // TODO: Location 없을 경우 얼럿 호출(위치정보권한 필요)
            isNowDataUploading.accept(false)
            return
        }

        /// place (도로명주소) 추가
        if classPlace == nil {
            group.enter()
            addressTransferUseCase.execute(
                location: classLocation,
                param: .detailAddress
            ) { [weak self] result in
                switch result {
                case .success(let address):
                    self?.classPlace = address
                case .failure(let error):
                    debugPrint(error)
                }
                group.leave()
            }
        }

        /// keyword 주소 추가 (@@구)
        group.enter()
        addressTransferUseCase.execute(location: classLocation, param: .keywordAddress) { [weak self] result in
            switch result {
                case .success(let keyword):
                    self?.classKeywordLocation = keyword
                case .failure(let error):
                    debugPrint(error)
            }
            group.leave()
        }

        /// semiKeyword 주소 추가 (@@동)
        group.enter()
        addressTransferUseCase.execute(location: classLocation, param: .semiKeywordAddress) { [weak self] result in
            switch result {
            case .success(let semiKeyword):
                self?.classSemiKeywordLocation = semiKeyword
            case .failure(let error):
                debugPrint(error)
            }
            group.leave()
        }

        group.notify(queue: .global()) { [weak self] in
            guard let self = self else { return }
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

            self.uploadClassItemUseCase.executeRx(param: .create(item: classItem))
                .subscribe(onCompleted: { [weak self] in
                    debugPrint("\(classItem) 등록")
                    self?.isNowDataUploading.accept(false)
                    self?.finishedUpload.onCompleted()
                })
                .disposed(by: self.disposeBag)
        }
    }

    // MARK: - Modify ClassItem
    func modifyClassItem() {
        isNowDataUploading.accept(true)

        let group = DispatchGroup()
        guard let classItem = classItem else {
            isNowDataUploading.accept(false)
            return
        }
        /// 수업 등록시 필수 항목 체크
        guard let className = className, let classDescription = classDescription else {
            isNowDataUploading.accept(false)
            occuredAlert.onNext(())
            return
        }
        /// 수업 판매 등록시
        if classItem.itemType == .sell, classTime == nil {
            isNowDataUploading.accept(false)
            occuredAlert.onNext(())
            return
        }

        /// 1. 삭제한 사진 Storage에서 삭제
        /// 2. 삭제하지 않은 사진 파악 -> Storage에 올리지 않기
        var existingImagesCount = 0
        classItem.images?.forEach { url in
            if classImagesURL?.contains(url) == false {
                imageUseCase.deleteImage(urlString: url) {}
            } else {
                existingImagesCount += 1
            }
        }
        if let classImages = classImages {
            for index in existingImagesCount ..< classImages.count {
                group.enter()
                imageUseCase.upload(image: classImages[index]) { [weak self] result in
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
            classLocation = locationUseCase.getCurrentLocation()
        }
        guard let classLocation = classLocation else {
            isNowDataUploading.accept(false)
            return
        }
        if classLocation != classItem.location {
            if classPlace == nil {
                group.enter()
                addressTransferUseCase.execute(location: classLocation, param: .detailAddress) { [weak self] result in
                    switch result {
                    case .success(let address):
                        self?.classPlace = address
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    }
                    group.leave()
                }
            }
            group.enter()
            addressTransferUseCase.execute(location: classLocation, param: .keywordAddress) { [weak self] result in
                switch result {
                case .success(let keyword):
                    self?.classKeywordLocation = keyword
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
                group.leave()
            }
            addressTransferUseCase.execute(location: classLocation, param: .semiKeywordAddress) { [weak self] result in
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
            self.isNowDataUploading.accept(false)
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

            self.uploadClassItemUseCase.executeRx(param: .update(item: modifiedClassItem))
                .subscribe(onCompleted: { [weak self] in
                    debugPrint("\(modifiedClassItem) 수정")
                    self?.isNowDataUploading.accept(false)
                    self?.modifiedClassItem.onNext(modifiedClassItem)
                    self?.finishedUpload.onCompleted()
                })
                .disposed(by: self.disposeBag)
        }
    }
}

// MARK: - INPUT
extension DefaultClassEnrollModifyViewModel {
    func inputImages(images: [UIImage]) {
        classImages = images.isEmpty ? nil : images
    }

    func inputImagesURL(imagesURL: [String]) {
        classImagesURL = imagesURL.isEmpty ? nil : imagesURL
    }

    func inputClassName(name: String?) {
        className = name
    }

    func inputTime(time: String?) {
        classTime = time
    }

    func inputDate(date: Set<DayWeek>) {
        classDate = date.isEmpty ? nil : date
    }

    func inputPlace(place: String?, location: Location?) {
        classPlace = place
        classLocation = location
    }

    func inputPrice(price: String?) {
        classPrice = price
    }

    func inputPriceUnit(priceUnit: PriceUnit) {
        classPriceUnit = priceUnit
    }

    func inputDescription(description: String?) {
        classDescription = description
    }

    func inputCategory(categoryType: CategoryType, categoryItems: [CategoryItem]) {
        switch categoryType {
        case .subject:
            let categoryList = Set(categoryItems.compactMap{$0 as? Subject})
            classSubject = categoryList.isEmpty ? nil : categoryList
        case .target:
            let categoryList = Set(categoryItems.compactMap{$0 as? Target})
            classTarget = categoryList.isEmpty ? nil : categoryList
        }
    }
}
