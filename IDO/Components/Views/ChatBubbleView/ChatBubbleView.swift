//
//  ChatBubbleView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 16/3/25.
//

import SwiftUI

struct ChatBubbleView: View {
    
    var text: String = "This is sample text."
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var showImage: Bool = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            
            if showImage {
                ImageView(imageName: "airobot")
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            }
                        
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(10)
            
            
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView()
            ChatBubbleView(text: "This is a chat bubble with a lot of text that wraps to multiple lines and it keeps on going. This is a chat bubble with a lot of text that wraps to multiple lines and it keeps on going.")
            
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                showImage: false
            )
            
            ChatBubbleView(
                text: "This is a chat bubble with a lot of text that wraps to multiple lines and it keeps on going. This is a chat bubble with a lot of text that wraps to multiple lines and it keeps on going.",
                textColor: .white,
                backgroundColor: .accent,
                showImage: false
            )
        }
        .padding()
    }
}
