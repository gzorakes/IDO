//
//  View+EXT.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 6/3/25.
//

import SwiftUI

extension View {
    
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent)
            .cornerRadius(16)
    }
    
    func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }
    
    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
    }
    
    func addingGradientBackgroundForText() -> some View {
        background(
            LinearGradient(
                colors: [
                    .black.opacity(0),
                    .black.opacity(0.3),
                    .black.opacity(0.4)
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
    }
}
