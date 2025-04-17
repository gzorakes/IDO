//
//  ImageGeneratorViewModel.swift
//  IDO
//
//  Created by George Zorakis on 17/4/25.
//
import SwiftUI

@MainActor
protocol ImageGeneratorInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: ImageGeneratorInteractor { }

@Observable
@MainActor
class ImageGeneratorViewModel {
    private let interactor: ImageGeneratorInteractor
    
    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var title: String?
    
    var textFieldText: String = ""
    var showAlert: AnyAppAlert?
    
    init(interactor: ImageGeneratorInteractor) {
        self.interactor = interactor
    }
    
    func onGenerateImagePressed() {
        
        let content = textFieldText
        let isValid = checkIfTextIsValid(text: content)
        if isValid {
            isGenerating = true
            textFieldText = ""
            
            Task {
                do {
                    generatedImage = try await interactor.generateImage(input: content)
                    
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
    
    private func checkIfTextIsValid(text: String) -> Bool {
        let minimumCharacterCount = 3
        
        guard text.count >= minimumCharacterCount else {
            return false
        }
        
        return true
    }
}
