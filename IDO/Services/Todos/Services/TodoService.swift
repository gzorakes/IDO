//
//  TodoService.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 27/3/25.
//

import SwiftUI

protocol TodoService: Sendable {
    func createTodo(todoItem: TodoItemModel) async throws
    func getTodos() async throws -> [TodoItemModel]
    func getTodosForCategory(category: String) async throws -> [TodoItemModel]
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel]
    func updateTodo(todoItem: TodoItemModel) async throws
    func deleteTodo(todoId: String) async throws
}
