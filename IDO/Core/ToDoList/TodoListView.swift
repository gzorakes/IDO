//
//  TodoListView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 12/3/25.
//

import SwiftUI
import PhotosUI

struct TodoListView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(TodoManager.self) private var todoManager
    
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
    }
    
    private func loadTodos() async {
        do {
            let currentUserId = try authManager.getAuthId()
            todoItems = try await todoManager.getTodosForAuthor(userId: currentUserId, category: category.rawValue)
        } catch {
            print("Error loading todo items")
        }
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
    
    private var addTextNoteSheet: some View {
        AddNoteView(onSave: { newNote in
            if !newNote.isEmpty || imageItem != nil {
                Task {
                    let content: TodoContent = imageItem.map { .image($0) } ?? .text(newNote)
                    let uid = try authManager.getAuthId()
                    
                    let newItem = TodoItemModel(
                        id: UUID().uuidString,
                        authorId: uid,
                        content: content,
                        categoryId: category.rawValue)
                    
                    try await todoManager.createTodo(todoItem: newItem )
                    
                    todoItems.insert(newItem, at: 0)
                    imageItem = nil
                }
            }
        }, itemToEdit: nil)
    }
    
    private func editTextNoteSheet(item: TodoItemModel) -> some View {
        AddNoteView(onSave: { updatedNote in
            Task {
                if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                    var updatedItem = todoItems[index]
                    updatedItem.content = .text(updatedNote)
                    
                    // Update in database
                    try await todoManager.updateTodo(todoItem: updatedItem)
                    
                    // Update local state
                    todoItems[index] = updatedItem
                }
            }
        }, itemToEdit: item)
    }
    
    private func imageSheet(wrapper: ImageWrapper) -> some View {
        VStack {
            Image(uiImage: wrapper.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func onChangeOfPhotoPicker() {
        Task {
            if let photosPickerItem,
               let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    let newItem = TodoItemModel(
                        id: UUID().uuidString,
                        authorId: "user1",
                        content: .image(image),
                        categoryId: category.rawValue)
                    todoItems.insert(newItem, at: 0)
                }
            }
            photosPickerItem = nil
        }
    }
    
    private func deleteItem(_ item: TodoItemModel) {
        Task {
            do {
                // Delete from Firestore
                try await todoManager.deleteTodo(todoId: item.id)
                
                // Remove from local state
                if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                    todoItems.remove(at: index)
                }
            } catch {
                print("Error deleting todo: \(error)")
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




