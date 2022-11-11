//
//  DataTransferService.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol DataTransferService {
//    func request()
}

public final class DefaultDataTransferService {

    private let firestoreManager: FirestoreManager

    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
}

extension DefaultDataTransferService: DataTransferService {
    func request() {
    }
}
