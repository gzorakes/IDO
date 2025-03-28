//
//  ChatBubbleViewBuilder.swift
//  IDO
//
//  Created by George Zorakis on 16/3/25.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    
    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    
    var body: some View {
        ChatBubbleView(
            text: message.content ?? "",
            textColor: isCurrentUser ? .white : .primary,
            backgroundColor: isCurrentUser ? .accent : Color(uiColor: .systemGray6),
            showImage: !isCurrentUser
        )
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.leading, isCurrentUser ? 85 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 85)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: "123123",
                    chatId: "124124",
                    authorId: "23423423",
                    content: "This is some longer content that goes on to multiple lines and keeps on going to another line!",
                    dateCreated: .now
                )
            )
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: "123123",
                    chatId: "124124",
                    authorId: "23423423",
                    content: "This is some longer content that goes on to multiple lines and keeps on going to another line!",
                    dateCreated: .now
                ),
                isCurrentUser: true
            )
        }
        .padding(12)
    }
}
