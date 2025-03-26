//
//  TodoListView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 12/3/25.
//

import SwiftUI
import PhotosUI

struct TodoListView: View {
    var category: CategoryModel
    @State private var textItems: [TodoItem] = []
    @State private var isShowingSheet = false
    @State private var imageItem: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: ImageWrapper?
    
    @State private var editingItem: TodoItem?
    
    var body: some View {
        List {
            todoItems
                .removeListRowFormatting()
        }
        .listSectionSpacing(14)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolBarButtons
        }
        .onAppear {
            textItems = TodoItem.mocks.filter { $0.categoryId == category.rawValue }
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
    
    @ViewBuilder
    private var todoItems: some View {
        if !textItems.isEmpty {
            ForEach(textItems) { item in
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
                let content: TodoContent = imageItem.map { .image($0) } ?? .text(newNote)
                let newItem = TodoItem(
                    id: UUID().uuidString,
                    content: content,
                    categoryId: category.rawValue)
                textItems.insert(newItem, at: 0)
                imageItem = nil
            }
        }, itemToEdit: nil)
    }
    
    private func editTextNoteSheet(item: TodoItem) -> some View {
        AddNoteView(onSave: { updatedNote in
            if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                textItems[index].content = .text(updatedNote)
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
                    let newItem = TodoItem(
                        id: UUID().uuidString,
                        content: .image(image),
                        categoryId: category.rawValue)
                    textItems.insert(newItem, at: 0)
                }
            }
            photosPickerItem = nil
        }
    }
    
    private func deleteItem(_ item: TodoItem) {
        if let index = textItems.firstIndex(where: { $0.id == item.id }) {
            textItems.remove(at: index)
        }
    }
}

#Preview {
    NavigationStack {
        TodoListView(category: CategoryModel.hall)
    }
}

