//
//  UserStorage.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

enum LoginType: String {
    case naver
    case email
    case kakao
}

protocol UserStorage {
    func initUserData(user: User)
    func isLogin() -> String?
    func getUserData() -> User?
    func getLoginType() -> LoginType?
    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping ()->())
    func updateUserData(user: User)
    func removeLoginStatus()
}
