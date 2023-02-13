//
//  ChatRepository.swift
//  ClassToday
//
//  Created by 박태현 on 2023/02/13.
//

import Foundation

protocol ChatRepository {
    // MARK: - Create
    func uploadChannel(channel: Channel)
    func uploadMatch(match: Match)

    // MARK: - Read
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

    // MARK: - Update
    func update(channel: Channel)

    // MARK: - Delete
    func delete(channel: Channel)
}
