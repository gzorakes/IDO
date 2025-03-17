//
//  TodoItem.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI

struct TodoItem: Identifiable {
    let id: String
    var text: String
    var image: UIImage?
    var categoryId: String
    
    static let mocks: [TodoItem] = [
        // Event Hall Tasks
        TodoItem(id: "1", text: "Book event hall", image: nil, categoryId: "hall"),
        TodoItem(id: "2", text: "Visit potential venues", image: nil, categoryId: "hall"),
        TodoItem(id: "3", text: "Sign venue contract", image: nil, categoryId: "hall"),
        
        // Church Tasks
        TodoItem(id: "4", text: "Book church ceremony", image: nil, categoryId: "church"),
        TodoItem(id: "5", text: "Meet with priest", image: nil, categoryId: "church"),
        
        // Invitations Tasks
        TodoItem(id: "6", text: "Design invitations", image: nil, categoryId: "invitations"),
        TodoItem(id: "7", text: "Send out invitations", image: nil, categoryId: "invitations"),
        
        // Flowers Tasks
        TodoItem(id: "8", text: "Choose wedding bouquet", image: nil, categoryId: "flowers"),
        TodoItem(id: "9", text: "Book florist for decorations", image: nil, categoryId: "flowers"),
        
        // Decoration Tasks
        TodoItem(id: "10", text: "Choose table centerpieces", image: nil, categoryId: "decoration"),
        TodoItem(id: "11", text: "Order decorations", image: nil, categoryId: "decoration"),
        
        // Dress Tasks
        TodoItem(id: "12", text: "Choose wedding dress", image: nil, categoryId: "dress"),
        TodoItem(id: "13", text: "Schedule dress fittings", image: nil, categoryId: "dress"),
        
        // Suit Tasks
        TodoItem(id: "14", text: "Choose groom's suit", image: nil, categoryId: "costume"),
        TodoItem(id: "15", text: "Schedule suit fittings", image: nil, categoryId: "costume"),
        
        // Music Tasks
        TodoItem(id: "16", text: "Book DJ or band", image: nil, categoryId: "music"),
        TodoItem(id: "17", text: "Create playlist", image: nil, categoryId: "music"),
        
        // Car Tasks
        TodoItem(id: "18", text: "Book wedding car", image: nil, categoryId: "car"),
        
        // Rings Tasks
        TodoItem(id: "19", text: "Order wedding rings", image: nil, categoryId: "rings"),
        
        // Notes Tasks
        TodoItem(id: "20", text: "Write vows", image: nil, categoryId: "notes"),
        
        // Guests Tasks
        TodoItem(id: "21", text: "Finalize guest list", image: nil, categoryId: "guests"),
        TodoItem(id: "22", text: "Arrange guest transportation", image: nil, categoryId: "guests")
    ]
}

struct ImageWrapper: Identifiable {
    let id = UUID().uuidString
    let image: UIImage
}
