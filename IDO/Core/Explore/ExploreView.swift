//
//  ExploreView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct ExploreView: View {
    
    @State private var categories: [CategoryModel] = CategoryModel.allCategories
    
    var body: some View {
        NavigationStack {
            List {
                categorySection
                
                
            }
            .navigationTitle("Explore")
        }
    }
    
    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            CategoryCellView(
                                title: category.title,
                                imageName: category.imageName
                            )
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
}

#Preview {
    ExploreView()
}



/*
 Section {
 ZStack {
 CarouselView(items: categories) { category in
 HeroCellView(title: category.title, imageName: category.imageName)
 }
 }
 .removeListRowFormatting()
 } header: {
 Text("Carousel")
 }
 */
