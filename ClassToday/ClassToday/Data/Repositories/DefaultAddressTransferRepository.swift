//
//  DefaultAddressTransferRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/22.
//

import Foundation

final class DefaultAddressTransferRepository {

    private let naverMapAPIProvider: NaverMapAPIProvider

    init(naverMapAPIProvider: NaverMapAPIProvider) {
        self.naverMapAPIProvider = naverMapAPIProvider
    }
}

extension DefaultAddressTransferRepository: AddressTransferRepository {
    func fetchAddress(location: Location, completion: @escaping (Result<AddrAPIResult, Error>) -> Void) {
        naverMapAPIProvider.locationToAddress(location: location, completion: completion)
    }
}
