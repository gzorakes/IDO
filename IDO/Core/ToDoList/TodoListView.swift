//
//  TodoListView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 12/3/25.
//

import SwiftUI

struct TodoListView: View {
    var category: CategoryModel
    @State private var textItems: [TodoItem] = []
    @State private var isShowingSheet = false
    
    var body: some View {
        ZStack {
            linearBackground()
            VStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<textItems.count + 1, id: \.self) { item in
                            if item % 2 == 0 {
                                HStack(spacing: 16) {
                                    if item < textItems.count {
                                        TodoListItemView(todoItem: textItems[item].text)
                                    } else {
                                        addNoteRectangle
                                    }
                                    
                                    if item + 1 < textItems.count {
                                        TodoListItemView(todoItem: textItems[item + 1].text)
                                    } else if item + 1 == textItems.count {
                                        addNoteRectangle
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(category.title)
            .sheet(isPresented: $isShowingSheet) {
                AddNoteView { newNote in
                    if !newNote.isEmpty {
                        let newItem = TodoItem(text: newNote)
                        textItems.append(newItem)
                    }
                }
            }
        }
    }
    
    var addNoteRectangle: some View {
        Button {
            isShowingSheet.toggle()
        } label: {
            ZStack {
                Rectangle()
                    .fill(.accent)
                    .frame(width: 170, height: 100)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    TodoListView(category: CategoryModel.car)
}


struct TodoListItemView: View {
    
    var todoItem: String = "This is a note"
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.accent)
                .frame(width: 170, height: 100)
                .cornerRadius(16)
                .shadow(radius: 5)
            ScrollView {
                VStack {
                    Text(todoItem)
                        .padding(4)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 170, height: 100)
        }
    }
}

#Preview("todolistitem") {
    TodoListItemView()
}



struct TodoItem: Identifiable {
    let id = UUID()
    let text: String
}




struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newNote: String = ""
    @FocusState private var isTextFieldFocused: Bool
    var onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.pink.opacity(0.4), .accent],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
                .ignoresSafeArea()
                VStack {
                    TextField("Type...", text: $newNote, axis: .vertical)
                        .lineLimit(5...)
                        .padding()
                        .autocorrectionDisabled()
                        .focused($isTextFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isTextFieldFocused = false
                                }
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true
                            }
                        }
                    
                    Spacer()
                }
                .navigationTitle("Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            onSave(newNote)
                            dismiss()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundStyle(.black)
                        }
                        .disabled(newNote.isEmpty)
                    }
                }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }
}
