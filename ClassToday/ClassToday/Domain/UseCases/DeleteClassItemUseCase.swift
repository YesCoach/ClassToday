//
//  DeleteClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/08.
//

import Foundation
import RxSwift

protocol DeleteClassItemUseCase {
    func executeRx(param: ClassItemQuery.DeleteItem) -> Observable<Void>
}

final class DefaultDeleteClassItemUseCase: DeleteClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    func executeRx(param: ClassItemQuery.DeleteItem) -> Observable<Void> {
        return Observable.create { emitter in
            self.classItemRepository.delete(param: param) {
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
