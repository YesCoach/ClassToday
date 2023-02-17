//
//  UploadClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/21.
//

import Foundation
import RxSwift

protocol UploadClassItemUseCase {
    func executeRx(param: ClassItemQuery.CreateItem) -> Observable<Void>
    func executeRx(param: ClassItemQuery.UpdateItem) -> Observable<Void>
}

final class DefaultUploadClassItemUseCase: UploadClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    func executeRx(param: ClassItemQuery.CreateItem) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            self?.classItemRepository.create(param: param) {
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }

    func executeRx(param: ClassItemQuery.UpdateItem) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            self?.classItemRepository.update(param: param) {
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
