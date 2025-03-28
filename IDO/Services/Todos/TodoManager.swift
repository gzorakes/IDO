//
//  TodoManager.swift
//  IDO
//
//  Created by George Zorakis on 26/3/25.
//

import SwiftUI


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
    
    func getTodos() async throws -> [TodoItemModel] {
        try await service.getTodos()
    }
    
    func getTodosForCategory(category: String) async throws -> [TodoItemModel] {
        try await service.getTodosForCategory(category: category)
    }
    
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel] {
        try await service.getTodosForAuthor(userId: userId, category: category)
    }
    
    func updateTodo(todoItem: TodoItemModel) async throws {
        try await service.updateTodo(todoItem: todoItem)
    }
    
    func deleteTodo(todoId: String) async throws {
        try await service.deleteTodo(todoId: todoId)
    }
}
