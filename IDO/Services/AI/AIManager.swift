//
//  AIManager.swift
//  IDO
//
//  Created by George Zorakis on 20/3/25.
//

import SwiftUI


@MainActor
@Observable
class AIManager  {
    
    private let service: AIService
    
    init(service: AIService) {
        self.service = service
    }
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
}
