//
//  ChatView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 16/3/25.
//

import SwiftUI

struct ChatView: View {
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var currentUser: UserModel? = .mock
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(chatMessages) { message in
                        let isCurrentUser = message.authorId == currentUser?.userId
                        ChatBubbleViewBuilder(
                            message: message,
                            isCurrentUser: isCurrentUser
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            }
            
            Rectangle()
                .frame(height: 50)
        }
        .navigationTitle(currentUser?.name ?? "Chat")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
