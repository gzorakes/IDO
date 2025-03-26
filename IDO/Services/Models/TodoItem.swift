//
//  TodoItem.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI

struct TodoItem: Identifiable {
    let id: String
    var content: TodoContent
    var categoryId: String
    
    static let mocks: [TodoItem] = [
        TodoItem(id: "1", content: .text("Book event hall"), categoryId: "hall"),
        TodoItem(id: "2", content: .text("Visit potential venues"), categoryId: "hall"),
        TodoItem(id: "3", content: .text("Sign venue contract"), categoryId: "hall"),
        TodoItem(id: "24", content: .image(UIImage(systemName: "star.fill")!), categoryId: "hall"),
        
        TodoItem(id: "4", content: .text("Book church ceremony"), categoryId: "church"),
        TodoItem(id: "5", content: .text("Meet with priest"), categoryId: "church"),
        
        TodoItem(id: "6", content: .text("Design invitations"), categoryId: "invitations"),
        TodoItem(id: "7", content: .text("Send out invitations"), categoryId: "invitations"),
        
        TodoItem(id: "8", content: .text("Choose wedding bouquet"), categoryId: "flowers"),
        TodoItem(id: "9", content: .text("Book florist for decorations"), categoryId: "flowers"),
        
        TodoItem(id: "10", content: .text("Choose table centerpieces"), categoryId: "decoration"),
        TodoItem(id: "11", content: .text("Order decorations"), categoryId: "decoration"),
        
        TodoItem(id: "12", content: .text("Choose wedding dress"), categoryId: "dress"),
        TodoItem(id: "13", content: .text("Schedule dress fittings"), categoryId: "dress"),
        
        TodoItem(id: "14", content: .text("Choose groom's suit"), categoryId: "costume"),
        TodoItem(id: "15", content: .text("Schedule suit fittings"), categoryId: "costume"),
        
        TodoItem(id: "16", content: .text("Book DJ or band"), categoryId: "music"),
        TodoItem(id: "17", content: .text("Create playlist"), categoryId: "music"),
        
        TodoItem(id: "18", content: .text("Book wedding car"), categoryId: "car"),
        
        TodoItem(id: "19", content: .text("Order wedding rings"), categoryId: "rings"),
        
        TodoItem(id: "20", content: .text("Write vows"), categoryId: "notes"),
        
        TodoItem(id: "21", content: .text("Finalize guest list"), categoryId: "guests"),
        TodoItem(id: "22", content: .text("Arrange guest transportation"), categoryId: "guests")
    ]
}

enum TodoContent {
    case text(String)
    case image(UIImage)
}

struct ImageWrapper: Identifiable {
    let id = UUID().uuidString
    let image: UIImage
}
