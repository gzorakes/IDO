//
//  TodoItemModel.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI
import IdentifiableByString

struct TodoItemModel: Identifiable, Codable, StringIdentifiable {
    let id: String
    let authorId: String
    var content: TodoContent
    let categoryId: String
    let createdAt: Date
    
    
    init(id: String, authorId: String, content: TodoContent, categoryId: String, createdAt: Date = Date()) {
        self.id = id
        self.authorId = authorId
        self.content = content
        self.categoryId = categoryId
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case content
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
    
    static let mocks: [TodoItemModel] = [
        TodoItemModel(id: "1", authorId: "user1", content: .text("Book event hall"), categoryId: "hall"),
        TodoItemModel(id: "2", authorId: "user1", content: .text("Visit potential venues"), categoryId: "hall"),
        TodoItemModel(id: "3", authorId: "user1", content: .text("Sign venue contract"), categoryId: "hall"),
        TodoItemModel(id: "24", authorId: "user1", content: .image(UIImage(named: "music2")!), categoryId: "hall"),
        
        TodoItemModel(id: "4", authorId: "user1", content: .text("Book church ceremony"), categoryId: "church"),
        TodoItemModel(id: "5", authorId: "user1", content: .text("Meet with priest"), categoryId: "church"),
        
        TodoItemModel(id: "6", authorId: "user1", content: .text("Design invitations"), categoryId: "invitations"),
        TodoItemModel(id: "7", authorId: "user1", content: .text("Send out invitations"), categoryId: "invitations"),
        
        TodoItemModel(id: "8", authorId: "user1", content: .text("Choose wedding bouquet"), categoryId: "flowers"),
        TodoItemModel(id: "9", authorId: "user1", content: .text("Book florist for decorations"), categoryId: "flowers"),
        
        TodoItemModel(id: "10", authorId: "user1", content: .text("Choose table centerpieces"), categoryId: "decoration"),
        TodoItemModel(id: "11", authorId: "user1", content: .text("Order decorations"), categoryId: "decoration"),
        
        TodoItemModel(id: "12", authorId: "user1", content: .text("Choose wedding dress"), categoryId: "dress"),
        TodoItemModel(id: "13", authorId: "user1", content: .text("Schedule dress fittings"), categoryId: "dress"),
        
        TodoItemModel(id: "14", authorId: "user1", content: .text("Choose groom's suit"), categoryId: "costume"),
        TodoItemModel(id: "15", authorId: "user1", content: .text("Schedule suit fittings"), categoryId: "costume"),
        
        TodoItemModel(id: "16", authorId: "user1", content: .text("Book DJ or band"), categoryId: "music"),
        TodoItemModel(id: "17", authorId: "user1", content: .text("Create playlist"), categoryId: "music"),
        
        TodoItemModel(id: "18", authorId: "user1", content: .text("Book wedding car"), categoryId: "car"),
        
        TodoItemModel(id: "19", authorId: "user1", content: .text("Order wedding rings"), categoryId: "rings"),
        
        TodoItemModel(id: "20", authorId: "user1", content: .text("Write vows"), categoryId: "notes"),
        
        TodoItemModel(id: "21", authorId: "user1", content: .text("Finalize guest list"), categoryId: "guests"),
        TodoItemModel(id: "22", authorId: "user1", content: .text("Arrange guest transportation"), categoryId: "guests")
    ]
}


enum TodoContent: Codable {
    case text(String)
    case image(UIImage)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    private enum ContentType: String, Codable {
        case text
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .text:
            let text = try container.decode(String.self, forKey: .value)
            self = .text(text)
        case .image:
            let data = try container.decode(Data.self, forKey: .value)
            if let image = UIImage(data: data) {
                self = .image(image)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .value, in: container, debugDescription: "Invalid image data")
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(text, forKey: .value)
        case .image(let image):
            try container.encode(ContentType.image, forKey: .type)
            if let data = image.pngData() {
                try container.encode(data, forKey: .value)
            } else {
                throw EncodingError.invalidValue(image, EncodingError.Context(codingPath: [CodingKeys.value], debugDescription: "Failed to convert UIImage to PNG data"))
            }
        }
    }
}

struct ImageWrapper: Identifiable {
    let id = UUID().uuidString
    let image: UIImage
}
