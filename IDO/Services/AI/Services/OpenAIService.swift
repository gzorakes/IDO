//
//  OpenAIService.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 20/3/25.
//

import OpenAI
import SwiftUI

struct OpenAIService: AIService {
    
    var openAI: OpenAI {
        OpenAI(apiToken: Keys.openAI)
    }
    
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            model: .dall_e_2,
            n: 1,
            quality: .hd,
            responseFormat: .b64_json,
            size: ._512,
            style: .natural,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
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
