//
//  AppView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct AppView: View {
    
    @Environment(\.authService) private var authService
    @State var appState: AppState = AppState()
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboadingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
    }
    
    private func checkUserStatus() async {
        if let user = authService.getAuthenticatedUser() {
            // User is authenticated
            print("User already authenticated: \(user.uid)")
        } else {
            // User is not authenticated
            
            do {
                let result = try await authService.signInAnonymously()
                
                // log in to app
                print("Sign in anonymous success: \(result.user.uid)")
            } catch {
                print(error)
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
