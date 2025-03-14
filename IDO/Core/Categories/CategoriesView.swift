//
//  CategoriesView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct CategoriesView: View {
    
    @State private var categories: [CategoryModel] = CategoryModel.allCategories
    @State private var path: [CategoryModel] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                linearBackground()
                VStack {
                    categoriesGrid
                        .removeListRowFormatting()
                }
                .navigationTitle("Categories")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: CategoryModel.self) { newValue in
                    TodoListView(category: newValue)
                }
            }
        }
    }
    
    private var categoriesGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: -30), count: 2),
            alignment: .center,
            spacing: 16,
            content: {
                Section {
                    ForEach(categories) { category in
                        HeroCellView(title: category.title, imageName: category.imageName, font: .callout)
                            .anyButton(.press) {
                                onCategoryPressed(category: category)
                            }
                            .frame(width: 160, height: 90)
                            .shadow(radius: 5)
                    }
                }
            }
        )
    }
    
    private func onCategoryPressed(category: CategoryModel) {
        path.append(category)
    }
}

#Preview {
    CategoriesView()
}
