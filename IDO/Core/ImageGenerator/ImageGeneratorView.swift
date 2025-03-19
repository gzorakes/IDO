//
//  ImageGeneratorView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 16/3/25.
//

import SwiftUI

struct ImageGeneratorView: View {
    
    @State private var textFieldText: String = ""
    @State private var showAlert: AnyAppAlert?
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var title: String?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            generatedImageSection
                .padding(.bottom, 150)
            textFieldSection
        }
        .navigationTitle("Image Generator")
        .toolbarTitleDisplayMode(.inline)
        .showCustomAlert(alert: $showAlert)
    }
    
    private var generatedImageSection: some View {
        VStack {
            if generatedImage != nil {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 350)
                    .overlay {
                        ZStack {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
            }
            
            if let title {
                Text(title)
                    .lineLimit(3...)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private var textFieldSection: some View {
        
        TextField("“Car decorated with pink roses“", text: $textFieldText, axis: .vertical)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 50)
            .overlay(alignment: .trailing) {
                if isGenerating {
                    ProgressView()
                        .padding(.trailing, 12)
                        .tint(.accent)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .padding(.trailing, 4)
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
//                            onSendMessagePressed()
                            onGenerateImagePressed()
                        }
                }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private func checkIfTextIsValid(text: String) -> Bool {
        let minimumCharacterCount = 3
        
        guard text.count >= minimumCharacterCount else {
            return false
        }
        
        return true
    }
    
    private func onGenerateImagePressed() {
        
        let content = textFieldText
        let isValid = checkIfTextIsValid(text: content)
        if isValid {
            
            isGenerating = true
            textFieldText = ""
            Task {
                try? await Task.sleep(for: .seconds(3))
                generatedImage = UIImage(systemName: "star.fill")
                title = content
                isGenerating = false
                
            }
        } else {
            showAlert = AnyAppAlert(title: "Please add at least 3 character")
        }
    }
}

#Preview {
    NavigationStack {
        ImageGeneratorView()
    }
}
