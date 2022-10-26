//
//  UserDefaultsManager.swift
//  ClassToday
//
//  Created by yc on 2022/07/27.
//

import Foundation

enum LoginType: String {
    case naver
    case email
    case kakao
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let statusKey = "LoginStatus"
    private let typeKey = "LoginType"
    private let userKey = "UserData"
    private let standard = UserDefaults.standard
    
    func isLogin() -> String? {
        return standard.string(forKey: statusKey)
    }
    
    func getUserData() -> User? {
        guard let data = standard.object(forKey: userKey) as? Data,
              let userData = try? PropertyListDecoder().decode(User.self, from: data) else {
            return nil
        }
        return userData
    }

    func getLoginType() -> LoginType? {
        guard let str = standard.string(forKey: typeKey) else { return nil }
        return LoginType(rawValue: str)
    }

    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping ()->()) {
        standard.set(uid, forKey: statusKey)
        standard.set(type.rawValue, forKey: typeKey)
        FirestoreManager.shared.readUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let userEncoder = try? PropertyListEncoder().encode(user)
                self.standard.set(userEncoder, forKey: self.userKey)
                completion()
            case .failure(let error):
                debugPrint(error)
                return
            }
        }
    }

    func removeLoginStatus() {
        standard.removeObject(forKey: statusKey)
        standard.removeObject(forKey: typeKey)
        standard.removeObject(forKey: userKey)
    }
}
