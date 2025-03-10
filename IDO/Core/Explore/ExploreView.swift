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
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 2),
                    spacing: 12,
                    content: {
                        Section {
                            ForEach(categories) { category in
                                HeroCellView(title: category.title, imageName: category.imageName, font: .callout)
                                    .frame(width: 170, height: 100)
                            }
                        }
                    }
                )
                .removeListRowFormatting()
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
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
