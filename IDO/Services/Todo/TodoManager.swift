//
//  TodoManager.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 26/3/25.
//

import SwiftUI

protocol TodoService: Sendable {
    func createTodo(todoItem: TodoItemModel) async throws
}


struct MockTodoService: TodoService {
    func createTodo(todoItem: TodoItemModel) async throws {
        
    }
}


import FirebaseFirestore
import SwiftfulFirestore
struct FirebaseTodoService: TodoService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("todos")
    }
    
    func createTodo(todoItem: TodoItemModel) async throws {
        try collection.document(todoItem.id).setData(from: todoItem, merge: true)
    }
}


@MainActor
@Observable
class TodoManager  {
    
    private let service: TodoService
    
    init(service: TodoService) {
        self.service = service
    }
    
    func createTodo(todoItem: TodoItemModel) async throws {
        try await service.createTodo(todoItem: todoItem)
    }
}
