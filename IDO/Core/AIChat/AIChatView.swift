//
//  AIChatView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct AIChatView: View {
    var body: some View {
        NavigationStack {
            
            ChatView()
                .navigationTitle("Chats")
            
        }
    }
}

#Preview {
    AIChatView()
}
