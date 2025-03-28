//
//  AppView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
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
        .onAppear {
            logManager.identifyUser(userId: "abc123", name: "george", email: "hi@hi.com")
            logManager.addUserProperties(dict: UserModel.mock.eventParameters)
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // User is authenticated
            print("User already authenticated: \(user.uid)")
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                print("Failed to log in to auth for existing user: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated
            
            do {
                let result = try await authManager.signInAnonymously()
                
                // log in to app
                print("Sign in anonymous success: \(result.user.uid)")
                // Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)

            } catch {
                print("Failed to sign in anonymously and log in: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))

}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
}
