//
//  ChatMessageModel.swift
//  IDO
//
//  Created by George Zorakis on 14/3/25.
//

import Foundation

struct ChatMessageModel: Identifiable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.dateCreated = dateCreated
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatMessageModel(id: "msg_1", chatId: "mock_chat_1", authorId: "user1", content: "Hello!", dateCreated: now),
            ChatMessageModel(id: "msg_2", chatId: "mock_chat_2", authorId: "user2", content: "How are you?", dateCreated: now.addingTimeInterval(hours: -1)),
            ChatMessageModel(id: "msg_3", chatId: "mock_chat_3", authorId: "user3", content: "Let's meet up.", dateCreated: now.addingTimeInterval(hours: -2)),
            ChatMessageModel(id: "msg_4", chatId: "mock_chat_4", authorId: "user1", content: "See you later.", dateCreated: now.addingTimeInterval(days: -1))
        ]
    }
}
