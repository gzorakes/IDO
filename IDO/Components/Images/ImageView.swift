//
//  ImageView.swift
//  IDO
//
//  Created by George Zorakis on 9/3/25.
//

import SwiftUI

struct ImageView: View {
    
    var imageName: String = "dress2"
    var resizingMode: ContentMode = .fill
    var offset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay(
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: resizingMode)
                    .offset(y: offset)
                    .allowsHitTesting(false)
            )
            .clipped()
        
    }
}

#Preview {
    ImageView()
        .frame(width: 300, height: 200)
}
