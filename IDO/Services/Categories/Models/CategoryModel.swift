//
//  CategoryModel.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 8/3/25.
//

import SwiftUI

struct CategoryModel: Identifiable, Hashable {
    let id: String
    let title: String
    let imageName: String
    
    static let allCategories: [CategoryModel] = [
        .init(id: "church", title: "Church", imageName: "church"),
        .init(id: "hall", title: "Hall", imageName: "eventhall"),
        .init(id: "invitations", title: "Invitations", imageName: "invitation"),
        .init(id: "flowers", title: "Flowers", imageName: "flowers"),
        .init(id: "decoration", title: "Decoration", imageName: "decoration"),
        .init(id: "dress", title: "Dress", imageName: "dress"),
        .init(id: "costume", title: "Suit", imageName: "suit"),
        .init(id: "music", title: "Music", imageName: "music"),
        .init(id: "car", title: "Car", imageName: "car"),
        .init(id: "rings", title: "Rings", imageName: "rings"),
        .init(id: "notes", title: "Notes", imageName: "notes")
    ]
}
