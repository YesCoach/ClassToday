//
//  UserUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

protocol UserUseCase {
    /// 앱 실행시 유저 정보를 최신화하기 위한 메서드
    func initUserData(user: User)
    
    /// 현재 로그인 상태인지 확인하는 메서드
    /// - Returns: User's UUID(Optional), not logged in when returns nil
    func isLogin() -> String?

    /// 현재 로그인된 User 정보를 반환하는 메서드
    /// - Returns: User?
    func getUserData() -> User?

    /// 로그인 유형을 반환하는 메서드
    /// - Returns: LoginType? (email, kakao, naver)
    func getLoginType() -> LoginType?

    /// 로그인 정보 및 유저 정보를 저장하는 메서드
    /// UserDefaults에 해당 정보 저장
    /// 저장이 끝나면 completion 후행 클로저 수행
    /// - Parameters :
    ///    - uid: User's UUID Value.
    ///    - type: User's Login Type.
    ///    - completion: escaping closure when save ends.
    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping ()->())

    /// 유저 정보 변경시 필수 호출 메서드
    /// - Parameters :
    /// - user: User to update
    func updateUserData(user: User)

    /// 로그아웃 시 로그인 정보 및 유저 정보를 삭제하는 메서드
    func removeLoginStatus()
}

final class DefaultUserUseCase: UserUseCase {

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func initUserData(user: User) {
        userRepository.initUserData(user: user)
    }

    func isLogin() -> String? {
        userRepository.isLogin()
    }

    func getUserData() -> User? {
        userRepository.getUserData()
    }

    func getLoginType() -> LoginType? {
        userRepository.getLoginType()
    }

    func saveLoginStatus(uid: String, type: LoginType, completion: @escaping () -> ()) {
        userRepository.saveLoginStatus(uid: uid, type: type, completion: completion)
    }

    func updateUserData(user: User) {
        userRepository.updateUserData(user: user)
    }

    func removeLoginStatus() {
        userRepository.removeLoginStatus()
    }
}
