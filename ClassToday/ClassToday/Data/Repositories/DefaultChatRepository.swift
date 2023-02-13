//
//  DefaultChatRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

final class DefaultChatRepository {

    private let firestoreManager: FirestoreManager
    
    init(firestoreManager: FirestoreManager = .shared) {
        self.firestoreManager = firestoreManager
    }
}

extension DefaultChatRepository: ChatRepository {
    func uploadChannel(channel: Channel) {
        firestoreManager.uploadChannel(channel: channel)
    }

    func uploadMatch(match: Match) {
        firestoreManager.uploadMatch(match: match)
    }

    func fetchMatch(userId: String, completion: @escaping ([Match]) -> ()) {
        firestoreManager.fetchMatch(userId: userId, completion: completion)
    }

    func fetchMatchBuy(userId: String, completion: @escaping ([Match]) -> ()) {
        firestoreManager.fetchMatchBuy(userId: userId, completion: completion)
    }

    func fetchChannel(channels: [String], completion: @escaping ([Channel]) -> ()) {
        firestoreManager.fetchChannel(channels: channels, completion: completion)
    }

    func fetch(channel: Channel, completion: @escaping (Channel) -> ()) {
        firestoreManager.fetch(channel: channel, completion: completion)
    }

    func checkChannel(
        sellerID: String,
        buyerID: String,
        classItemID: String,
        completion: @escaping ([Channel]) -> ()
    ) {
        firestoreManager.checkChannel(
            sellerID: sellerID,
            buyerID: buyerID,
            classItemID: classItemID,
            completion: completion
        )
    }

    func update(channel: Channel) {
        firestoreManager.update(channel: channel)
    }
    
    func delete(channel: Channel) {
        firestoreManager.delete(channel: channel)
    }
}
