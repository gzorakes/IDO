//
//  TodoListView.swift
//  IDO
//
//  Created by George Zorakis on 12/3/25.
//

import SwiftUI
import PhotosUI


struct TodoListView: View {
    
    @State var viewModel: TodoListViewModel
    var category: CategoryModel
    
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
            await viewModel.loadTodos(category: category)
        }
        .sheet(isPresented: $viewModel.isShowingSheet) {
            addTextNoteSheet
        }
        .sheet(item: $viewModel.editingItem) { item in
            editTextNoteSheet(item: item)
        }
        .sheet(item: $viewModel.selectedImage) { wrapper in
            imageSheet(wrapper: wrapper)
        }
        .onChange(of: viewModel.photosPickerItem) {
            viewModel.onChangeOfPhotoPicker(category: category)
        }
        .screenAppearAnalytics(name: "TodoListView")
    }
    
    @ViewBuilder
    private var todoItemsList: some View {
        if !viewModel.todoItems.isEmpty {
            ForEach(viewModel.todoItems) { item in
                Section {
                    TodoListItemView(
                        selectedImage: $viewModel.selectedImage,
                        todoItem: item,
                        onEdit: {
                            viewModel.editingItem = item
                        }
                    )
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteItem(item)
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
                        viewModel.isShowingSheet = true
                    }
                PhotosPicker(selection: $viewModel.photosPickerItem) {
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
    
    private func editTextNoteSheet(item: TodoItemModel) -> some View {
        AddNoteView(onSave: { updatedNote in
            Task {
                await viewModel.editTodo(item: item, updatedNote: updatedNote)
            }
        }, itemToEdit: item)
    }
    
    private var addTextNoteSheet: some View {
        AddNoteView(onSave: { newNote in
            if !newNote.isEmpty || viewModel.imageItem != nil {
                Task {
                    await viewModel.addNewTodo(note: newNote, category: category)
                }
            }
        }, itemToEdit: nil)
    }
}


#Preview {
    NavigationStack {
        TodoListView(
            viewModel: TodoListViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)),
            category: CategoryModel.hall
        )
        .previewEnvironment()
    }
}
