//
//  UserRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2022/11/11.
//

import Foundation

protocol UserRepository {
    
    // MARK: - Server
    func uploadUser(user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func readUser(uid: String, completion: @escaping (Result<User, Error>) -> Void)

    // MARK: - Local
    // MARK: - Create
    func initUserData(user: User)

    // MARK: - Read
    func isLogin() -> String?
    func getUserData() -> User?
    func getLoginType() -> LoginType?

    // MARK: - Update
    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping ()->())
    func updateUserData(user: User)

    // MARK: - Delete
    func removeLoginStatus()
}
