//
//  AppView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(DependencyContainer.self) private var container
    @State var appState: AppState = AppState()
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboadingView: {
                WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container)))
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            await showATTPromptIfNeeded()
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    enum Event: LoggableEvent {
        
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart:     return "AppView_ExistingAuth_Start"
            case .existingAuthFail:      return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:         return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:       return "AppView_AnonAuth_Success"
            case .anonAuthFail:          return "AppView_AnonAuth_Fail"
            case .attStatus:             return "AppView_ATTStatus"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // User is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated
            logManager.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await authManager.signInAnonymously()
                
                // log in to app
                logManager.trackEvent(event: Event.anonAuthSuccess)
                
                // Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .previewEnvironment()
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))

}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .previewEnvironment()
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
}
