//
//  TodoItem.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI

struct TodoItem: Identifiable {
    let id: String
    let text: String
    let image: UIImage?
}

struct ImageWrapper: Identifiable {
    let id = UUID().uuidString
    let image: UIImage
}
