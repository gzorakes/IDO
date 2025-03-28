//
//  IDOApp.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 3/3/25.
//

import SwiftUI
import Firebase


@main
struct IDOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.todoManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    /*
     This is not a force unwrap,
     in this instance means that
     we are for sure going to create
     and set auth manager before we
     try to fetch and get the value for it
     
     When we use @Observable the initializer
     can run multiple times, but the result
     of the first one is the only one that's
     actually going to be used.
     
     This way we initialize the managers
     outside of the SwiftUi view lifecycles,
     and initialize it only once!
     
     */
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        #if MOCK
        dependencies = Dependencies(config: .mock(isSignedIn: true))
        #elseif DEV
        dependencies = Dependencies(config: .dev)
        #else
        dependencies = Dependencies(config: .prod)
        #endif

        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
}


@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let todoManager: TodoManager
    
    init(config: BuildConfiguration) {
        
        // Mock - mock dependencies
        // Development - production dependencies + some extra dev tools
        // Production - production dependencies

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            aiManager = AIManager(service: MockAIService())
            todoManager = TodoManager(service: MockTodoService())

        case .dev:
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductionUserServices())
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())

        case .prod:
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductionUserServices())
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())

        }
    }
}


extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(TodoManager(service: MockTodoService()))
            .environment(AppState())
            .environment(AIManager(service: MockAIService()))
    }
}
