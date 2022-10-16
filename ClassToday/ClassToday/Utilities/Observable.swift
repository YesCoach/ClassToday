//
//  Observable.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/13.
//

import Foundation

final class Observable<T> {
    // 클로저
    typealias Listner = (T) -> Void
    var listener: Listner?

    var value: T {
        // 값이 변하면 클로저 실행
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: Listner?) {
        self.listener = listener
        listener?(value)
    }
}

