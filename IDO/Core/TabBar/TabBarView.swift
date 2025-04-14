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
                    logManager: logManager
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
}
