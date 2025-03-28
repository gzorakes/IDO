//
//  AIService.swift
//  IDO
//
//  Created by George Zorakis on 20/3/25.
//

import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
}
