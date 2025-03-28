//
//  CategoryCellView.swift
//  IDO
//
//  Created by George Zorakis on 8/3/25.
//

import SwiftUI

struct CategoryCellView: View {
    
    var title: String = "Title"
    var imageName: String = "car"
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .overlay(alignment: .bottomLeading) {
                    Text(title)
                        .font(font)
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .addingGradientBackgroundForText()
                }
        }
        .frame(width: 150, height: 150)
        .clipped()
        .cornerRadius(cornerRadius)
    }
    
}

#Preview {
    VStack {
        CategoryCellView()
            .frame(width: 150)
    }
}
