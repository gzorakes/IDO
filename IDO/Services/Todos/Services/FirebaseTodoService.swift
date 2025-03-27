//
//  FirebaseTodoService.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 27/3/25.
//

import FirebaseFirestore
import SwiftfulFirestore


struct FirebaseTodoService: TodoService {

    var collection: CollectionReference {
        Firestore.firestore().collection("todos")
    }
    
    func createTodo(todoItem: TodoItemModel) async throws {
        try collection.document(todoItem.id).setData(from: todoItem, merge: true)
    }
    
    func getTodos() async throws -> [TodoItemModel] {
        try await collection.getAllDocuments()
    }
    
    func getTodosForCategory(category: String) async throws -> [TodoItemModel] {
        try await collection
            .whereField(TodoItemModel.CodingKeys.categoryId.rawValue, isEqualTo: category)
            .getAllDocuments()
    }
    
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel] {
        try await collection
            .whereField(TodoItemModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .whereField(TodoItemModel.CodingKeys.categoryId.rawValue, isEqualTo: category)
            .order(by: TodoItemModel.CodingKeys.createdAt.rawValue, descending: true)
            .getAllDocuments()
    }
    
    func updateTodo(todoItem: TodoItemModel) async throws {
        try collection.document(todoItem.id).setData(from: todoItem, merge: true)
    }
    
    func deleteTodo(todoId: String) async throws {
        try await collection.document(todoId).delete()
    }
    
}
