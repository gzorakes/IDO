//
//  AddNoteView.swift
//  IDO
//
//  Created by George Zorakis on 14/3/25.
//

import SwiftUI

struct AddNoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var newNote: String = ""
    var onSave: (String) -> Void
    var itemToEdit: TodoItemModel?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.001) // keeping a background for tapping and dismiss the keyboard
                VStack {
                    TextField("Type...", text: $newNote, axis: .vertical)
                        .lineLimit(5...)
                        .autocorrectionDisabled()
                        .padding()
                        .focused($isTextFieldFocused)
                        .onAppear {
                            isTextFieldFocused = true
                            if case let .text(text) = itemToEdit?.content {
                                newNote = text
                            }
                        }
                    
                    Spacer()
                }
                .navigationTitle(itemToEdit == nil ? "Add Note" : "Edit Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            onSave(newNote)
                            dismiss()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundStyle(.primary)
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


#Preview {
    AddNoteView(onSave: {_ in })
}
