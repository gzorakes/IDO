//
//  TodoListView.swift
//  IDO
//
//  Created by George Zorakis on 12/3/25.
//

import SwiftUI
import PhotosUI

struct TodoListView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(TodoManager.self) private var todoManager
    @Environment(LogManager.self) private var logManager
    
    var category: CategoryModel
    @State private var todoItems: [TodoItemModel] = []
    @State private var isShowingSheet = false
    @State private var imageItem: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: ImageWrapper?
    @State private var editingItem: TodoItemModel?
    
    
    var body: some View {
        List {
            todoItemsList
                .removeListRowFormatting()
        }
        .listSectionSpacing(12)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolBarButtons
        }
        .task {
            await loadTodos()
        }
        .sheet(isPresented: $isShowingSheet) {
            addTextNoteSheet
        }
        .sheet(item: $editingItem) { item in
            editTextNoteSheet(item: item)
        }
        .sheet(item: $selectedImage) { wrapper in
            imageSheet(wrapper: wrapper)
        }
        .onChange(of: photosPickerItem) {
            onChangeOfPhotoPicker()
        }
        .screenAppearAnalytics(name: "TodoListView")
    }
    
    @ViewBuilder
    private var todoItemsList: some View {
        if !todoItems.isEmpty {
            ForEach(todoItems) { item in
                Section {
                    TodoListItemView(
                        selectedImage: $selectedImage,
                        todoItem: item,
                        onEdit: {
                            editingItem = item
                        }
                    )
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        } else {
            Text("Your list is empty...")
                .foregroundStyle(.secondary)
                .padding(40)
                .frame(maxWidth: .infinity)
        }
    }
    
    
    private var toolBarButtons: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.accent)
                    .anyButton {
                        isShowingSheet = true
                    }
                PhotosPicker(selection: $photosPickerItem) {
                    Image(systemName: "photo")
                        .offset(y: 1)
                }
            }
        }
    }
    
    private func imageSheet(wrapper: ImageWrapper) -> some View {
        VStack {
            Image(uiImage: wrapper.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var addTextNoteSheet: some View {
        AddNoteView(onSave: { newNote in
            if !newNote.isEmpty || imageItem != nil {
                logManager.trackEvent(event: Event.addTodoStart)
                Task {
                    do {
                        let content: TodoContent = imageItem.map { .image($0) } ?? .text(newNote)
                        let uid = try authManager.getAuthId()
                        
                        let newItem = TodoItemModel(
                            id: UUID().uuidString,
                            authorId: uid,
                            content: content,
                            categoryId: category.rawValue)
                        
                        try await todoManager.createTodo(todoItem: newItem)
                        
                        todoItems.insert(newItem, at: 0)
                        imageItem = nil
                        logManager.trackEvent(event: Event.addTodoSuccess)
                    } catch {
                        logManager.trackEvent(event: Event.addTodoFail(error: error))
                    }
                }
            }
        }, itemToEdit: nil)
    }
    
    private func loadTodos() async {
        logManager.trackEvent(event: Event.loadTodoStart)
        do {
            let currentUserId = try authManager.getAuthId()
            todoItems = try await todoManager.getTodosForAuthor(userId: currentUserId, category: category.rawValue)
            logManager.trackEvent(event: Event.loadTodoSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadTodoFail(error: error))
        }
    }
    
    private func editTextNoteSheet(item: TodoItemModel) -> some View {
        AddNoteView(onSave: { updatedNote in
            logManager.trackEvent(event: Event.editTodoStart)
            Task {
                do {
                    if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                        var updatedItem = todoItems[index]
                        updatedItem.content = .text(updatedNote)
                        
                        // Update in database
                        try await todoManager.updateTodo(todoItem: updatedItem)
                        
                        // Update local state
                        todoItems[index] = updatedItem
                        
                        logManager.trackEvent(event: Event.editTodoSuccess)
                    }
                } catch {
                    logManager.trackEvent(event: Event.editTodoFail(error: error))
                }
            }
        }, itemToEdit: item)
    }
    
    
    private func onChangeOfPhotoPicker() {
        logManager.trackEvent(event: Event.imagePickerSelected)
        Task {
            if let photosPickerItem {
                do {
                    let data = try await photosPickerItem.loadTransferable(type: Data.self)
                    guard let data = data else {
                        logManager.trackEvent(event: Event.imagePickerFailed(error: ImagePickerError.dataConversionFailed))
                        return
                    }
                    
                    guard let image = UIImage(data: data) else {
                        logManager.trackEvent(event: Event.imagePickerFailed(error: ImagePickerError.imageCreationFailed))
                        return
                    }
                    
                    let uid = try authManager.getAuthId()
                    let newItem = TodoItemModel(
                        id: UUID().uuidString,
                        authorId: uid,
                        content: .image(image),
                        categoryId: category.rawValue)
                    
                    todoItems.insert(newItem, at: 0)
                } catch {
                    logManager.trackEvent(event: Event.imagePickerFailed(error: error))
                }
            }
            photosPickerItem = nil
        }
    }
    
    // Add this error type somewhere in your file (could be in the Event enum file)
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
    
    private func deleteItem(_ item: TodoItemModel) {
        logManager.trackEvent(event: Event.deleteTodoStart)

        Task {
            do {
                // Delete from Firestore
                try await todoManager.deleteTodo(todoId: item.id)
                
                // Remove from local state
                if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                    todoItems.remove(at: index)
                }
                logManager.trackEvent(event: Event.deleteTodoSuccess)
            } catch {
                logManager.trackEvent(event: Event.deleteTodoFail(error: error))
            }
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

#Preview {
    NavigationStack {
        TodoListView(category: CategoryModel.hall)
            .previewEnvironment()
    }
}




