//
//  TodoListItemView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI

struct TodoListItemView: View {
    
    @Binding var selectedImage: ImageWrapper?
    var todoItem: TodoItem
    var onEdit: () -> Void
    var onDelete: () -> Void

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
            }
        }
        .onLongPressGesture {
            onDelete()
        }
        .anyButton {
            onEdit()
        }
        
    }
}

#Preview {
    TodoListItemView(
        selectedImage: .constant(nil),
        todoItem: TodoItem(
            id: "1234",
            text: "This is an item",
            image: nil,
            categoryId: "car"
        ),
        onEdit: { },
        onDelete: { }
    )
}
