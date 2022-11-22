//
//  AddressTransferRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import Foundation

protocol AddressTransferRepository {
    func fetchAddress(location: Location, completion: @escaping (Result<AddrAPIResult, Error>) -> Void)
}
