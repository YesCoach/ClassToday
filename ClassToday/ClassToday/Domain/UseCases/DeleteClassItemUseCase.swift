//
//  DeleteClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/08.
//

import Foundation

protocol DeleteClassItemUseCase {
    func execute(param: ClassItemQuery.DeleteItem, completion: @escaping () -> ())
}

final class DefaultDeleteClassItemUseCase: DeleteClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    func execute(param: ClassItemQuery.DeleteItem, completion: @escaping () -> ()) {
        classItemRepository.delete(param: param, completion: completion)
    }
}
