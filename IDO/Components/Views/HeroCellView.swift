//
//  HeroCellView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 8/3/25.
//

import SwiftUI

struct HeroCellView: View {
    
    var title: String? = "This is the title"
    var imageName: String? = "rings"
    var font: Font = .headline
    
    var body: some View {
        ZStack {
            if let imageName {
                ImageView(imageName: imageName, offset: 10)
            } else {
                Rectangle()
                    .fill(.accent)
            }
        }
        .overlay(
            alignment: .bottomLeading,
            content: {
                VStack(alignment: .leading) {
                    if let title {
                        Text(title)
                            .font(font)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .addingGradientBackgroundForText()
            })
        .cornerRadius(16)
    }
}

#Preview {
    ScrollView {
        VStack {
            HeroCellView()
                .frame(width: 300, height: 200)
            
            HeroCellView()
                .frame(width: 300, height: 400)
            
            HeroCellView()
                .frame(width: 200, height: 200)
            
            HeroCellView(imageName: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView(title: nil)
                .frame(width: 300, height: 200)
            
        }
        .frame(maxWidth: .infinity)
    }
}
