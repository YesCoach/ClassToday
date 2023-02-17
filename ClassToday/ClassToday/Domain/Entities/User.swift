//
//  User.swift
//  ClassToday
//
//  Created by yc on 2022/03/29.
//

import UIKit
import RxSwift

enum LoginError: Error {
    case notLoggedIn
}

struct User: Codable, Equatable {
    var id: String = UUID().uuidString
    let name: String
    let nickName: String
    let gender: String
    var location: String?
    /// 주소 문자열(@@시 ##구)
    var detailLocation: String?
    /// 키워드 주소 문자열(##구)
    var keywordLocation: String?
    let email: String
    let profileImage: String?
    let company: String?
    let description: String?
    var stars: [String]?
    let subjects: [Subject]?
    var channels: [String]?
    
    func thumbnailImage(completion: @escaping (UIImage?) -> Void) {
        guard let profileImageURL = profileImage else {
            return completion(nil)
        }
        if let cachedImage = ImageCacheManager.shared.object(forKey: profileImageURL as NSString) {
            completion(cachedImage)
        }
        StorageManager.shared.downloadImage(urlString: profileImageURL) { result in
            switch result {
            case .success(let image):
                ImageCacheManager.shared.setObject(image, forKey: profileImageURL as NSString)
                completion(image)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func thumbnailImageRX() -> Observable<UIImage?> {
        return Observable.create { emitter in
            guard let profileImageURL = profileImage else {
                emitter.onNext(nil)
                emitter.onCompleted()

                return Disposables.create()
            }
            StorageManager.shared.downloadImage(urlString: profileImageURL) { result in
                switch result {
                case .success(let image):
                    ImageCacheManager.shared.setObject(image, forKey: profileImageURL as NSString)
                    emitter.onNext(image)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    /// Rx 적용한 getCurrentUser 메서드
    /// 성공시 onNext로 user 값 전달
    /// 실패시 onError로 error 전달, onCompleted 필요 x
    /// 마지막에 Disposables 생성해서 반환
    static func getCurrentUserRx() -> Observable<User> {
        return Observable.create() { emitter in
            guard let user = UserDefaultsManager.shared.getUserData() else {
                emitter.onError(LoginError.notLoggedIn)
                return Disposables.create()
            }
            emitter.onNext(user)
            emitter.onCompleted()

            return Disposables.create()
        }
    }

    static func getCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let user = UserDefaultsManager.shared.getUserData() else {
            completion(.failure(LoginError.notLoggedIn))
            return
        }
        completion(.success(user))
    }
}
