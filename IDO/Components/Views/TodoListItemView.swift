//
//  TodoListItemView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI

struct TodoListItemView: View {
    
    var todoItem: TodoItem
    @Binding var selectedImage: ImageWrapper?
    var onEdit: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.accent)
                .frame(width: 170, height: 100)
                .cornerRadius(16)
                .shadow(radius: 5)
                
            
            if let image = todoItem.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 100)
                    .cornerRadius(16)
                    .clipped()
                    .onTapGesture {
                        selectedImage = ImageWrapper(image: image)
                    }
            } else {
                ScrollView {
                    VStack {
                        Text(todoItem.text)
                            .padding(6)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                .frame(width: 170, height: 100)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "pencil")
                        .foregroundColor(.accent)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(6)
                        .anyButton {
                            onEdit()
                        }
                }
            }
        }
        
    }
}

#Preview {
    TodoListItemView(todoItem: TodoItem(id: "1234", text: "This is an item", image: nil), selectedImage: .constant(nil), onEdit: {})
}
