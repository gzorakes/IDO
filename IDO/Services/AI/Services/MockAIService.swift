//
//  MockAIService.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 20/3/25.
//

import SwiftUI

struct MockAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        try? await Task.sleep(for: .seconds(2))
        return UIImage(systemName: "star.fill")!
    }
}
