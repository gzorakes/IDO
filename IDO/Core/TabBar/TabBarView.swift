//
//  TabBarView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        TabView {
            CategoriesView(
                viewModel: CategoriesViewModel(container: container)
            )
            .tabItem {
                Label("Notes", systemImage: "list.clipboard")
            }
            
//            ImageGeneratorView()
//                .tabItem {
//                    Label("AI Generator", systemImage: "sparkles")
//                }
            
            AccountView(
                viewModel: AccountViewModel(interactor: ProdAccountInteractor(container: container), container: container)
            )
            .tabItem {
                Label("Account", systemImage: "person")
            }
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
