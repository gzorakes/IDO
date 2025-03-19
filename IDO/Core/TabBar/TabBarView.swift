//
//  TabBarView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {
            CategoriesView()
                .tabItem {
                    Label("Notes", systemImage: "list.clipboard")
                }
                
            ImageGeneratorView()
                .tabItem {
                    Label("AI Chat", systemImage: "brain.head.profile")
                }
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
    }
}

#Preview {
    TabBarView()
        .environment(AppState())
}
