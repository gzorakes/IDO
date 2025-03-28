//
//  TodoListItemView.swift
//  IDO
//
//  Created by George Zorakis on 14/3/25.
//

import SwiftUI

struct TodoListItemView: View {
    
    @Binding var selectedImage: ImageWrapper?
    var todoItem: TodoItemModel
    var onEdit: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#FF9BA1"),
                            Color(hex: "#82AEE6"),
                            Color(hex: "#FFC1C5"),
                            Color(hex: "#A5C6F1")

                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Color.black.opacity(0.15))
                .frame(maxWidth: .infinity)
                .frame(height: todoItem.content.isImage ? 110 : 55)

            switch todoItem.content {
            case .text(let text):
                ScrollView {
                    VStack {
                        Text(text)
                            .padding(6)
                            .foregroundStyle(.black)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                    .clipped()
                    .onTapGesture {
                        selectedImage = ImageWrapper(image: image)
                    }
            }
        }
        .anyButton {
            onEdit()
        }
        
    }
}

#Preview {
    List {
        Section {
            TodoListItemView(
                selectedImage: .constant(nil),
                todoItem: TodoItemModel(
                    id: "1234",
                    authorId: "user1",
                    content: .text("This is an item"),
                    categoryId: "car"
                ),
                onEdit: { }
            )
            .removeListRowFormatting()
        }
        
        Section {
            TodoListItemView(
                selectedImage: .constant(nil),
                todoItem: TodoItemModel(
                    id: "1234",
                    authorId: "user1",
                    content: .text("This is an item"),
                    categoryId: "car"
                ),
                onEdit: { }
            )
            .removeListRowFormatting()
        }
        
        Section {
            TodoListItemView(
                selectedImage: .constant(nil),
                todoItem: TodoItemModel(
                    id: "1234",
                    authorId: "user1",
                    content: .image(UIImage(systemName: "photo.artframe")!),
                    categoryId: "car"
                ),
                onEdit: { }
            )
            .removeListRowFormatting()
        }
    }
    .listSectionSpacing(12)
    
}


extension TodoContent {
    var isImage: Bool {
        if case .image = self { return true }
        return false
    }
}
