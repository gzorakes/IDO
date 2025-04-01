//
//  TabBarView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
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
                    Label("AI Generator", systemImage: "sparkles")
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
//        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService()))
        .environment(UserManager(services: MockUserServices(user: .mock)))
}
