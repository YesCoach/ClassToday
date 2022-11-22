//
//  UploadClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import Foundation

protocol UploadClassItemUseCase {
    func excute(param: ClassItemQuery.CreateItem, completion: @escaping () -> ())
    func excute(param: ClassItemQuery.UpdateItem, completion: @escaping () -> ())
}

final class DefaultUploadClassItemUseCase: UploadClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    func excute(param: ClassItemQuery.CreateItem, completion: @escaping () -> ()) {
        classItemRepository.create(param: param, completion: completion)
    }

    func excute(param: ClassItemQuery.UpdateItem, completion: @escaping () -> ()) {
        classItemRepository.update(param: param, completion: completion)
    }
}
