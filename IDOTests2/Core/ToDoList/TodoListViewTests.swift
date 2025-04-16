//
//  TodoListViewTests.swift
//  IDOTests2
//
//  Created by George Zorakis on 16/4/25.
//

import Testing
import SwiftUI
@testable import IDO

@MainActor
struct TodoListViewTests {
    
    @Test("Load Todos for Specific Category")
    func testLoadTodosForCategory() async throws {
        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService(user: UserAuthInfo.mock()))
        let todoManager = TodoManager(service: MockTodoService())
        let logManager = LogManager(services: [MockLogService()])
        let todos = TodoItemModel.mocks
        
        container.register(AuthManager.self, service: authManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        
        let viewModel = TodoListViewModel(container: container)
        let category: CategoryModel = .hall
        let filteredItems = todos.filter { $0.categoryId == category.rawValue }
        
        await viewModel.loadTodos(category: category)
        
        #expect(viewModel.todoItems.count == filteredItems.count)
    }
    
    @Test("Add new todo to category")
    func testAddNewTodo() async throws {
        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService(user: UserAuthInfo.mock()))
        let todoManager = TodoManager(service: MockTodoService())
        let logManager = LogManager(services: [MockLogService()])
        
        container.register(AuthManager.self, service: authManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        
        let viewModel = TodoListViewModel(container: container)
        let category: CategoryModel = .hall
        let note = "Buy wedding flowers"
        
        await viewModel.addNewTodo(note: note, category: category)
        
        let addedItem = viewModel.todoItems.first
        
        #expect(addedItem != nil)
        #expect(addedItem?.categoryId == category.rawValue)
    }
    
    @Test("Edit existing todo item")
    func testEditTodoItem() async throws {
        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService(user: UserAuthInfo.mock()))
        let todoManager = TodoManager(service: MockTodoService())
        let logManager = LogManager(services: [MockLogService()])
        
        container.register(AuthManager.self, service: authManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        
        let viewModel = TodoListViewModel(container: container)
        viewModel.todoItems = TodoItemModel.mocks
        let originalItem = TodoItemModel.mocks[0]
        let updatedText = "Updated note content"
        
        await viewModel.editTodo(item: originalItem, updatedNote: updatedText)
        
        let editedItem = viewModel.todoItems.first { $0.id == originalItem.id }
        
        #expect(editedItem != nil)
    }
    
    @Test("Delete todo item successfully")
    func testDeleteTodoSuccess() async throws {
        let container = DependencyContainer()
        
        let logService = MockLogService()
        let authManager = AuthManager(service: MockAuthService(user: UserAuthInfo.mock()))
        let todoManager = TodoManager(service: MockTodoService())
        let logManager = LogManager(services: [logService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        
        let viewModel = TodoListViewModel(container: container)
        viewModel.todoItems = TodoItemModel.mocks
        let itemToDelete = TodoItemModel.mocks[0]
        
        viewModel.deleteItem(itemToDelete)
        try? await Task.sleep(for: .seconds(1))
        
        #expect(viewModel.todoItems.contains(where: { $0.id == itemToDelete.id }) == false)
    }
}
