//
//  TodoListViewModel.swift
//  IDO
//
//  Created by George Zorakis on 17/4/25.
//
import SwiftUI
import PhotosUI

@MainActor
protocol TodoListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAuthId() throws -> String
    func createTodo(todoItem: TodoItemModel) async throws
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel]
    func updateTodo(todoItem: TodoItemModel) async throws
    func deleteTodo(todoId: String) async throws
}

extension CoreInteractor: TodoListInteractor { }

@Observable
@MainActor
class TodoListViewModel {
    let interactor: TodoListInteractor
    
    private(set) var imageItem: UIImage?
    
    var todoItems: [TodoItemModel] = []
    var photosPickerItem: PhotosPickerItem?
    var selectedImage: ImageWrapper?
    var editingItem: TodoItemModel?
    var isShowingSheet = false
    
    init(interactor: TodoListInteractor) {
        self.interactor = interactor
    }
    
    func addNewTodo(note: String, category: CategoryModel) async {
        interactor.trackEvent(event: Event.addTodoStart)
        do {
            let content: TodoContent = imageItem.map { .image($0) } ?? .text(note)
            let uid = try interactor.getAuthId()
            
            let newItem = TodoItemModel(
                id: UUID().uuidString,
                authorId: uid,
                content: content,
                categoryId: category.rawValue)
            
            try await interactor.createTodo(todoItem: newItem)
            
            todoItems.insert(newItem, at: 0)
            imageItem = nil
            interactor.trackEvent(event: Event.addTodoSuccess)
        } catch {
            interactor.trackEvent(event: Event.addTodoFail(error: error))
        }
    }
    
    func loadTodos(category: CategoryModel) async {
        interactor.trackEvent(event: Event.loadTodoStart)
        do {
            let currentUserId = try interactor.getAuthId()
            todoItems = try await interactor.getTodosForAuthor(userId: currentUserId, category: category.rawValue)
            interactor.trackEvent(event: Event.loadTodoSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadTodoFail(error: error))
        }
    }
    
    
    
    func editTodo(item: TodoItemModel, updatedNote: String) async {
        interactor.trackEvent(event: Event.editTodoStart)
        do {
            if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                var updatedItem = todoItems[index]
                updatedItem.content = .text(updatedNote)
                
                // Update in database
                try await interactor.updateTodo(todoItem: updatedItem)
                
                // Update local state
                todoItems[index] = updatedItem
                
                interactor.trackEvent(event: Event.editTodoSuccess)
            }
        } catch {
            interactor.trackEvent(event: Event.editTodoFail(error: error))
        }
    }
    
    
    func onChangeOfPhotoPicker(category: CategoryModel) {
        interactor.trackEvent(event: Event.imagePickerSelected)
        Task {
            if let photosPickerItem {
                do {
                    let data = try await photosPickerItem.loadTransferable(type: Data.self)
                    guard let data = data else {
                        interactor.trackEvent(event: Event.imagePickerFailed(error: ImagePickerError.dataConversionFailed))
                        return
                    }
                    
                    guard let image = UIImage(data: data) else {
                        interactor.trackEvent(event: Event.imagePickerFailed(error: ImagePickerError.imageCreationFailed))
                        return
                    }
                    
                    let uid = try interactor.getAuthId()
                    let newItem = TodoItemModel(
                        id: UUID().uuidString,
                        authorId: uid,
                        content: .image(image),
                        categoryId: category.rawValue)
                    
                    todoItems.insert(newItem, at: 0)
                } catch {
                    interactor.trackEvent(event: Event.imagePickerFailed(error: error))
                }
            }
            photosPickerItem = nil
        }
    }
    
    func deleteItem(_ item: TodoItemModel) {
        interactor.trackEvent(event: Event.deleteTodoStart)

        Task {
            do {
                // Delete from Firestore
                try await interactor.deleteTodo(todoId: item.id)
                
                // Remove from local state
                if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                    todoItems.remove(at: index)
                }
                interactor.trackEvent(event: Event.deleteTodoSuccess)
            } catch {
                interactor.trackEvent(event: Event.deleteTodoFail(error: error))
            }
        }
    }
    
    enum ImagePickerError: Error, CustomStringConvertible {
        case dataConversionFailed
        case imageCreationFailed
        
        var description: String {
            switch self {
            case .dataConversionFailed:
                return "Failed to convert photo data"
            case .imageCreationFailed:
                return "Failed to create image from data"
            }
        }
        
        var eventParameters: [String: Any] {
            return ["errorDescription": description]
        }
    }
    
    
    enum Event: LoggableEvent {
        case loadTodoStart
        case loadTodoSuccess
        case loadTodoFail(error: Error)
        case addTodoStart
        case addTodoSuccess
        case addTodoFail(error: Error)
        case editTodoStart
        case editTodoSuccess
        case editTodoFail(error: Error)
        case deleteTodoStart
        case deleteTodoSuccess
        case deleteTodoFail(error: Error)
        case imagePickerSelected
        case imagePickerFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .loadTodoStart:       return "TodoListView_LoadTodo_Start"
            case .loadTodoSuccess:     return "TodoListView_LoadTodo_Success"
            case .loadTodoFail:        return "TodoListView_LoadTodo_Fail"
            case .addTodoStart:        return "TodoListView_AddTodo_Start"
            case .addTodoSuccess:      return "TodoListView_AddTodo_Success"
            case .addTodoFail:         return "TodoListView_AddTodo_Fail"
            case .editTodoStart:       return "TodoListView_EditTodo_Start"
            case .editTodoSuccess:     return "TodoListView_EditTodo_Success"
            case .editTodoFail:        return "TodoListView_EditTodo_Fail"
            case .deleteTodoStart:     return "TodoListView_DeleteTodo_Start"
            case .deleteTodoSuccess:   return "TodoListView_DeleteTodo_Success"
            case .deleteTodoFail:      return "TodoListView_DeleteTodo_Fail"
            case .imagePickerSelected: return "TodoListView_ImagePicker_Selected"
            case .imagePickerFailed:  return "TodoListView_ImagePicker_Failed"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .loadTodoFail(error: let error),
                    .addTodoFail(error: let error),
                    .editTodoFail(error: let error),
                    .deleteTodoFail(error: let error),
                    .imagePickerFailed(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadTodoFail,
                    .addTodoFail,
                    .editTodoFail,
                    .deleteTodoFail,
                    .imagePickerFailed:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
