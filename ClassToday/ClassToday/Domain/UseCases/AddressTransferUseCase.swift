//
//  AddressTransferUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import Foundation

// TODO: Data Mapping 구현 및 반영하기

protocol AddressTransferUseCase {
    func execute(location: Location, param: DefaultAddressTransferUseCase.Request, completion: @escaping (Result<String, Error>) -> Void)
}

final class DefaultAddressTransferUseCase: AddressTransferUseCase {

    private let addressTransferRepository: AddressTransferRepository

    enum Request {
        /// 도로명주소
        case detailAddress
        /// 주소("@@시 ##구")
        case keywordFullAddress
        /// 주소("##구")
        case keywordAddress
        /// 주소("$$동")
        case semiKeywordAddress
    }

    init(addressTransferRepository: AddressTransferRepository) {
        self.addressTransferRepository = addressTransferRepository
    }

    func execute(location: Location, param: Request, completion: @escaping (Result<String, Error>) -> Void) {
        addressTransferRepository.fetchAddress(location: location) { result in
            switch result {
            case .success(let data):
                let address: [String]
                switch param {
                case .detailAddress:
                    address = [
                        data.region.area1.name, data.region.area2.name,
                        data.region.area3.name, data.region.area4.name,
                        data.land.name, data.land.number1, data.land.addition0.value
                    ].compactMap {$0}
                case .keywordFullAddress:
                    address = [
                        data.region.area1.name, data.region.area2.name
                    ].compactMap {$0}
                case .keywordAddress :
                    address = [
                        data.region.area2.name
                    ].compactMap {$0}
                case .semiKeywordAddress:
                    address = [
                        data.region.area3.name
                    ].compactMap {$0}
                }
                let addrString = (address as AnyObject).componentsJoined(by: " ")
                completion(.success(addrString))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
