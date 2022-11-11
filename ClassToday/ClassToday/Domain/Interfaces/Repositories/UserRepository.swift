//
//  UserRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol UserRepository {
    func readUser(id: String)
    func postUser(user: User)
}
