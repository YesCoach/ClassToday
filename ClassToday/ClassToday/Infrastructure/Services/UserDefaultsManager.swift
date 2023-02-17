//
//  UserDefaultsManager.swift
//  ClassToday
//
//  Created by yc on 2022/07/27.
//

import Foundation

class UserDefaultsManager {

    static let shared = UserDefaultsManager()

    private let statusKey = "LoginStatus"
    private let typeKey = "LoginType"
    private let userKey = "UserData"
    private let standard = UserDefaults.standard

    private init() {}

    /// 현재 로그인 상태인지 확인하는 메서드
    ///
    /// return: User의 UUID(Optional)
    /// nil일 경우 비로그인 상태를 의미
    func isLogin() -> String? {
        return standard.string(forKey: statusKey)
    }
    
    /// 현재 로그인된 User 정보를 반환하는 메서드
    ///
    /// return: User?
    func getUserData() -> User? {
        guard let data = standard.object(forKey: userKey) as? Data,
              let userData = try? PropertyListDecoder().decode(User.self, from: data) else {
            return nil
        }
        return userData
    }

    /// 로그인 유형을 반환하는 메서드
    ///
    /// return: LoginType? (email, kakao, naver)
    func getLoginType() -> LoginType? {
        guard let str = standard.string(forKey: typeKey) else { return nil }
        return LoginType(rawValue: str)
    }

    /// 로그인 정보 및 유저 정보를 저장하는 메서드
    ///
    /// UserDefaults에 해당 정보 저장
    /// 저장이 끝나면 completion 후행 클로저 수행
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

    /// 유저 정보 변경시 필수 호출 메서드
    /// - Parameter user: <#user description#>
    func updateUserData(user: User) {
        let userEncoder = try? PropertyListEncoder().encode(user)
        self.standard.set(userEncoder, forKey: self.userKey)
        NotificationCenter.default.post(name: NSNotification.Name("updateUserData"), object: nil, userInfo: nil)
    }

    /// 로그아웃 시 로그인 정보 및 유저 정보를 삭제하는 메서드
    func removeLoginStatus() {
        standard.removeObject(forKey: statusKey)
        standard.removeObject(forKey: typeKey)
        standard.removeObject(forKey: userKey)
    }

    /// 앱 실행시 유저 정보를 최신화하기 위한 메서드
    func initUserData(user: User) {
        let userEncoder = try? PropertyListEncoder().encode(user)
        self.standard.set(userEncoder, forKey: self.userKey)
    }
}
