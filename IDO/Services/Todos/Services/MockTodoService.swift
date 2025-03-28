//
//  MockTodoService.swift
//  IDO
//
//  Created by George Zorakis on 27/3/25.
//

import SwiftUI

struct MockTodoService: TodoService {
    
    let todos: [TodoItemModel]
    
    init(todos: [TodoItemModel] = TodoItemModel.mocks) {
        self.todos = todos
    }
    
    func createTodo(todoItem: TodoItemModel) async throws {
        
    }
    
    func getTodos() async throws -> [TodoItemModel] {
        todos
    }
    
    func getTodosForCategory(category: String) async throws -> [TodoItemModel] {
        todos.filter { $0.categoryId == category }
    }
    
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel] {
        todos.filter { $0.categoryId == category }
    }
    
    func updateTodo(todoItem: TodoItemModel) async throws {
        
    }
    
    func deleteTodo(todoId: String) async throws {
        
    }
}
