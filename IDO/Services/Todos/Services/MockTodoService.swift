//
//  MockTodoService.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 27/3/25.
//

import SwiftUI

struct MockTodoService: TodoService {
    
    func createTodo(todoItem: TodoItemModel) async throws {
        
    }
    
    func getTodos() async throws -> [TodoItemModel] {
        TodoItemModel.mocks
    }
    
    func getTodosForCategory(category: String) async throws -> [TodoItemModel] {
        TodoItemModel.mocks.filter { $0.categoryId == category }
    }
    
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel] {
        TodoItemModel.mocks
    }
    
    func updateTodo(todoItem: TodoItemModel) async throws {
        
    }
}
