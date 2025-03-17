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
    
    @State private var editingItem: TodoItem? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    todoItems
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolBarButtons
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
    
    private var todoItems: some View {
        ForEach(0..<textItems.count, id: \.self) { index in
            if index % 2 == 0 {
                HStack(spacing: 16) {
                    TodoListItemView(todoItem: textItems[index], selectedImage: $selectedImage, onEdit: {
                        editingItem = textItems[index]
                    })
                    
                    if index + 1 < textItems.count {
                        TodoListItemView(todoItem: textItems[index + 1], selectedImage: $selectedImage, onEdit: {
                            editingItem = textItems[index + 1]
                        })
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 170, height: 100)
                    }
                }
            }
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
                let newItem = TodoItem(id: UUID().uuidString, text: newNote, image: imageItem)
                textItems.append(newItem)
                imageItem = nil
            }
        }, itemToEdit: nil)
    }
    
    private func editTextNoteSheet(item: TodoItem) -> some View {
        AddNoteView(onSave: { updatedNote in
            if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                textItems[index].text = updatedNote
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
                    let newItem = TodoItem(id: UUID().uuidString, text: "", image: image)
                    textItems.append(newItem)
                }
            }
            photosPickerItem = nil
        }
    }
}

#Preview {
    NavigationStack {
        TodoListView(category: CategoryModel.car)
    }
}

