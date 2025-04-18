//
//  Dependencies.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let todoManager: TodoManager
    let logManager: LogManager
    let pushManager: PushManager
    let appState: AppState
    
    init(config: BuildConfiguration) {
        
        // Mock - mock dependencies
        // Development - production dependencies + some extra dev tools
        // Production - production dependencies

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiManager = AIManager(service: MockAIService())
            todoManager = TodoManager(service: MockTodoService())
            appState = AppState(showTabBar: isSignedIn)

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)/*, FirebaseAnalyticsService()*/, MixPanelService(token: Keys.mixPanelToken, loggingEnabled: false)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())
            appState = AppState()
            
        case .prod:
            logManager = LogManager(services: [
                /*FirebaseAnalyticsService(), */MixPanelService(token: Keys.mixPanelToken)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())
            appState = AppState()
        }
        
        pushManager = PushManager(logManager: logManager)
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(AppState.self, service: appState)
        self.container = container
    }
}


extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(DevPreview.shared.container)
            .environment(LogManager(services: []))
    }
}



@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    /*
     Because we are using a shared instance, meaning that all the previews
     accesing the same container. So if all compiling at the same time, they are
     going to update the container at the same time
     So rather than initializing one on launch, we create a new container for
     every preview. So every time we call container, we run the calculated variable.
     (calculated variables trigger every time you access them)
     So every time we return a new container
     */
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(AppState.self, service: appState)
        return container
    }
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let todoManager: TodoManager
    let logManager: LogManager
    let pushManager: PushManager
    let appState: AppState
    
    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.aiManager = AIManager(service: MockAIService())
        self.todoManager = TodoManager(service: MockTodoService())
        self.logManager = LogManager(services: [])
        self.pushManager = PushManager()
        self.appState = AppState()
    }
}
