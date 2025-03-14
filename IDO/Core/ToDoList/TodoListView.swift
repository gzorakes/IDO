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

    
    var body: some View {
        ZStack {
            linearBackground()
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
                textNoteSheet
            }
            .sheet(item: $selectedImage) { wrapper in
                imageSheet(wrapper: wrapper)
            }
            .onChange(of: photosPickerItem) {
                onChangeOfPhotoPicker()
            }
        }
    }
    
    private var todoItems: some View {
        ForEach(0..<textItems.count, id: \.self) { index in
            if index % 2 == 0 {
                HStack(spacing: 16) {
                    TodoListItemView(todoItem: textItems[index], selectedImage: $selectedImage)
                    
                    if index + 1 < textItems.count {
                        TodoListItemView(todoItem: textItems[index + 1], selectedImage: $selectedImage)
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
    
    private var textNoteSheet: some View {
        AddNoteView { newNote in
            if !newNote.isEmpty || imageItem != nil {
                let newItem = TodoItem(text: newNote, image: imageItem)
                textItems.append(newItem)
                imageItem = nil
            }
        }
    }
    
    private func imageSheet(wrapper: ImageWrapper) -> some View {
        VStack {
            Image(uiImage: wrapper.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [.pink.opacity(0.4), .accent.opacity(0.6)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: UIScreen.main.bounds.height / 2
                    )
                )
        }
    }
    
    private func onChangeOfPhotoPicker() {
        Task {
            if let photosPickerItem,
               let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    let newItem = TodoItem(text: "", image: image)
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

