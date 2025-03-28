//
//  ImageGeneratorView.swift
//  IDO
//
//  Created by George Zorakis on 16/3/25.
//

import SwiftUI

struct ImageGeneratorView: View {
    
    @Environment(AIManager.self) private var aiManager
    
    @State private var textFieldText: String = ""
    @State private var showAlert: AnyAppAlert?
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var title: String?
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            generatedImageSection
            Spacer()
            textFieldSection
        }
        .navigationTitle("Image Generator")
        .toolbarTitleDisplayMode(.inline)
        .showCustomAlert(alert: $showAlert)
    }
    
    private var generatedImageSection: some View {
        VStack {
            if let generatedImage = generatedImage {
                Image(uiImage: generatedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 320)
                    .overlay {
                        VStack(alignment: .leading) {
                            Text("Examples")
                            
                            Group {
                                Text("«Groom in a navy suit, black bow tie»")
                                    
                                Text("«Bride in white lace gown, holding roses»")
                                Text("«Sunset beach ceremony, couple under an arch»")
                                Text("«Santorini wedding, blue domes, breathtaking views»")
                                    
                            }
                            .font(.footnote)
                            .italic()
                            
                            Spacer()
                            
                            Text("AI can make mistakes. Τhe result is not always what you expect")
                                .italic()
                                .font(.caption2)
                        }
                        .baselineOffset(10)
                        .foregroundStyle(.secondary)
                        .padding(8)
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
        
        TextField("Type...", text: $textFieldText)
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
                do {
                    generatedImage = try await aiManager.generateImage(input: content)
                    
                    title = content
                } catch {
                    print("Error generating image: \(error)")
                }
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
            .environment(AIManager(service: MockAIService()))
    }
}
