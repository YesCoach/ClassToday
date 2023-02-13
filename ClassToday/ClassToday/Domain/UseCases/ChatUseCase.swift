//
//  ChatUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation
import RxSwift

protocol ChatUseCase {
    func uploadChannel(channel: Channel)
    func uploadMatch(match: Match)
    func fetchMatch(userId: String, completion: @escaping ([Match]) -> ())
    func fetchMatchBuy(userId: String, completion: @escaping ([Match]) -> ())
    func fetchChannel(channels: [String], completion: @escaping ([Channel]) -> ())
    func fetch(channel: Channel, completion: @escaping (Channel) -> ())
    func checkChannel(
        sellerID: String,
        buyerID: String,
        classItemID: String,
        completion: @escaping ([Channel]) -> ()
    )
    func update(channel: Channel)
    func delete(channel: Channel)

    // MARK: - RxSwift 메서드

    func fetchMatchRx(userID: String) -> Observable<[Match]>
    func fetchMatchBuyRx(userID: String) -> Observable<[Match]>
    func fetchChannelRx(channels: [String]) -> Observable<[Channel]>
    func fetchRx(channel: Channel) -> Observable<Channel>
    func checkChannelRx(
        sellerID: String,
        buyerID: String,
        classItemID: String
    ) -> Observable<[Channel]>
}

final class DefaultChatUseCase: ChatUseCase {

    private let chatRepository: ChatRepository

    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    func uploadChannel(channel: Channel) {
        chatRepository.uploadChannel(channel: channel)
    }

    func uploadMatch(match: Match) {
        chatRepository.uploadMatch(match: match)
    }

    func fetchMatch(userId: String, completion: @escaping ([Match]) -> ()) {
        chatRepository.fetchMatch(userId: userId, completion: completion)
    }

    func fetchMatchBuy(userId: String, completion: @escaping ([Match]) -> ()) {
        chatRepository.fetchMatchBuy(userId: userId, completion: completion)
    }

    func fetchChannel(channels: [String], completion: @escaping ([Channel]) -> ()) {
        chatRepository.fetchChannel(channels: channels, completion: completion)
    }

    func fetch(channel: Channel, completion: @escaping (Channel) -> ()) {
        chatRepository.fetch(channel: channel, completion: completion)
    }

    func checkChannel(
        sellerID: String,
        buyerID: String,
        classItemID: String,
        completion: @escaping ([Channel]) -> ()
    ) {
        chatRepository.checkChannel(
            sellerID: sellerID,
            buyerID: buyerID,
            classItemID: classItemID,
            completion: completion
        )
    }

    func update(channel: Channel) {
        chatRepository.update(channel: channel)
    }

    func delete(channel: Channel) {
        chatRepository.delete(channel: channel)
    }
}

// MARK: - RxSwift 메서드 구현부

extension DefaultChatUseCase {
    func fetchMatchRx(userID: String) -> Observable<[Match]> {
        return Observable.create() { emitter in
            self.chatRepository.fetchMatch(userId: userID) { matches in
                emitter.onNext(matches)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }

    func fetchMatchBuyRx(userID: String) -> Observable<[Match]> {
        return Observable.create() { emitter in
            self.chatRepository.fetchMatchBuy(userId: userID) { matches in
                emitter.onNext(matches)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }

    func fetchChannelRx(channels: [String]) -> Observable<[Channel]> {
        return Observable.create() { emitter in
            self.chatRepository.fetchChannel(channels: channels) { channels in
                emitter.onNext(channels)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }

    func fetchRx(channel: Channel) -> Observable<Channel> {
        return Observable.create() { emitter in
            self.chatRepository.fetch(channel: channel) { channel in
                emitter.onNext(channel)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }

    func checkChannelRx(
        sellerID: String,
        buyerID: String,
        classItemID: String
    ) -> Observable<[Channel]> {
        return Observable.create() { emitter in
            self.chatRepository.checkChannel(
                sellerID: sellerID,
                buyerID: buyerID,
                classItemID: classItemID
            ) { channels in
                emitter.onNext(channels)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
