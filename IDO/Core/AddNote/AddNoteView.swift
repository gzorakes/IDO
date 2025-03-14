//
//  AddNoteView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 14/3/25.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var newNote: String = ""
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
                        .autocorrectionDisabled()
                        .padding()
                        .focused($isTextFieldFocused)
                        .onAppear {
                            isTextFieldFocused = true
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


#Preview {
    AddNoteView(onSave: {_ in })
}
