//
//  UserDefaultsUser.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

final class UserDefaultsUser {
    private let userDefaults: UserDefaults

    private let statusKey = "LoginStatus"
    private let typeKey = "LoginType"
    private let userKey = "UserData"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsUser: UserStorage {
    func isLogin() -> String? {
        return userDefaults.string(forKey: statusKey)
    }

    func getUserData() -> User? {
        guard let data = userDefaults.object(forKey: userKey) as? Data,
              let userData = try? PropertyListDecoder().decode(User.self, from: data) else {
            return nil
        }
        return userData
    }

    func getLoginType() -> LoginType? {
        guard let str = userDefaults.string(forKey: typeKey) else { return nil }
        return LoginType(rawValue: str)
    }

    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping ()->()) {
        userDefaults.set(uid, forKey: statusKey)
        userDefaults.set(type.rawValue, forKey: typeKey)
        FirestoreManager.shared.readUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let userEncoder = try? PropertyListEncoder().encode(user)
                self.userDefaults.set(userEncoder, forKey: self.userKey)
                completion()
            case .failure(let error):
                debugPrint(error)
                return
            }
        }
    }

    func updateUserData(user: User) {
        let userEncoder = try? PropertyListEncoder().encode(user)
        userDefaults.set(userEncoder, forKey: self.userKey)
        NotificationCenter.default.post(
            name: NSNotification.Name("updateUserData"),
            object: nil,
            userInfo: nil
        )
    }

    func removeLoginStatus() {
        userDefaults.removeObject(forKey: statusKey)
        userDefaults.removeObject(forKey: typeKey)
        userDefaults.removeObject(forKey: userKey)
    }

    func initUserData(user: User) {
        let userEncoder = try? PropertyListEncoder().encode(user)
        userDefaults.set(userEncoder, forKey: self.userKey)
    }
}
