//
//  TabBarView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(AppState.self) private var appState
    
    
    var body: some View {
        TabView {
            CategoriesView()
                .tabItem {
                    Label("Notes", systemImage: "list.clipboard")
                }
            
//            ImageGeneratorView()
//                .tabItem {
//                    Label("AI Generator", systemImage: "sparkles")
//                }
            AccountView(
                viewModel: AccountViewModel(
                    authManager: authManager,
                    userManager: userManager,
                    logManager: logManager,
                    appState: appState
                )
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
    //        .environment(AppState())
    //        .environment(AIManager(service: MockAIService()))
    //        .environment(AuthManager(service: MockAuthService()))
    //        .environment(UserManager(services: MockUserServices(user: .mock)))
}
