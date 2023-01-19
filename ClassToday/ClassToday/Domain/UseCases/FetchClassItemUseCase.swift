//
//  ClassItemUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation
import RxSwift

protocol FetchClassItemUseCase {
    func excute(param: ClassItemQuery.FetchItems, completion: @escaping ([ClassItem]) -> ())
    func excute(param: ClassItemQuery.FetchItem, completion: @escaping (ClassItem) -> ())
    
    func excuteRx(param: ClassItemQuery.FetchItems) -> Observable<[ClassItem]>
    func excuteRx(param: ClassItemQuery.FetchItem) -> Observable<ClassItem>
}

final class DefaultFetchClassItemUseCase: FetchClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    func excute(param: ClassItemQuery.FetchItems, completion: @escaping ([ClassItem]) -> ()) {
        classItemRepository.fetchItems(param: param, completion: completion)
    }

    func excute(param: ClassItemQuery.FetchItem, completion: @escaping (ClassItem) -> ()) {
        classItemRepository.fetchItem(param: param, completion: completion)
    }
    
    func excuteRx(param: ClassItemQuery.FetchItems) -> Observable<[ClassItem]> {
        return Observable.create() { emitter in
            self.classItemRepository.fetchItems(param: param) { classItems in
                emitter.onNext(classItems)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func excuteRx(param: ClassItemQuery.FetchItem) -> Observable<ClassItem> {
        return Observable.create() { emitter in
            self.classItemRepository.fetchItem(param: param) { classItem in
                emitter.onNext(classItem)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
