//
//  DefaultUserRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

final class DefaultUserRepository {

    private let firestoreManager: FirestoreManager
    private let userPersistentStorage: UserStorage

    init(firestoreManager: FirestoreManager, userPersistentStorage: UserStorage) {
        self.firestoreManager = firestoreManager
        self.userPersistentStorage = userPersistentStorage
    }
}

extension DefaultUserRepository: UserRepository {
    func uploadUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        firestoreManager.uploadUser(user: user, completion: completion)
    }

    func readUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        firestoreManager.readUser(uid: uid, completion: completion)
    }

    func initUserData(user: User) {
        userPersistentStorage.initUserData(user: user)
    }

    func isLogin() -> String? {
        return userPersistentStorage.isLogin()
    }

    func getUserData() -> User? {
        return userPersistentStorage.getUserData()
    }

    func getLoginType() -> LoginType? {
        return userPersistentStorage.getLoginType()
    }

    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping () -> ()) {
        return userPersistentStorage.saveLoginStatus(
            uid: uid,
            type: type,
            completion: completion
        )
    }

    func updateUserData(user: User) {
        userPersistentStorage.updateUserData(user: user)
    }

    func removeLoginStatus() {
        userPersistentStorage.removeLoginStatus()
    }
}
