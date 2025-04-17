//
//  ImageGeneratorView.swift
//  IDO
//
//  Created by George Zorakis on 16/3/25.
//
import SwiftUI


struct ImageGeneratorView: View {
    
    @State var viewModel: ImageGeneratorViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            generatedImageSection
            Spacer()
            textFieldSection
        }
        .navigationTitle("Image Generator")
        .toolbarTitleDisplayMode(.inline)
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    private var generatedImageSection: some View {
        VStack {
            if let generatedImage = viewModel.generatedImage {
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
            
            if let title = viewModel.title {
                Text(title)
                    .lineLimit(3...)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private var textFieldSection: some View {
        TextField("Type...", text: $viewModel.textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 50)
            .overlay(alignment: .trailing) {
                if viewModel.isGenerating {
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
                            viewModel.onGenerateImagePressed()
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
}

#Preview {
    NavigationStack {
        ImageGeneratorView(viewModel: ImageGeneratorViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
            .environment(AIManager(service: MockAIService()))
    }
}
