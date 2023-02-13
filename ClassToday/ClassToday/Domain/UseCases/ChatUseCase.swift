//
//  ChatUseCase.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

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
