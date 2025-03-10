//
//  ImageView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 9/3/25.
//

import SwiftUI

struct ImageView: View {
    
    var imageName: String = "eventhall"
    var resizingMode: ContentMode = .fill
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay(
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false)
            )
            .clipped()
        
    }
}

#Preview {
    ImageView()
        .frame(width: 300, height: 200)
}
