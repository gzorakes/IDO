//
//  OpenAIService.swift
//  IDO
//
//  Created by George Zorakis on 20/3/25.
//

import SwiftUI
import FirebaseFunctions

struct OpenAIService: AIService {
    
    func generateImage(input: String) async throws -> UIImage {
        
        let response = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])
        
        
        guard
            let b64Json = response.data as? String,
            let data = Data(base64Encoded: b64Json),
            let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}
