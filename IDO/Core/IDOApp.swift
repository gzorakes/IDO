//
//  IDOApp.swift
//  IDO
//
//  Created by George Zorakis on 3/3/25.
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
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.pushManager)
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
        
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        config.configure()
        dependencies = Dependencies(config: config)
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            // Mock build does not run Firebase
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)

        }
    }
}


@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let todoManager: TodoManager
    let logManager: LogManager
    let pushManager: PushManager
    
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

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: false), FirebaseAnalyticsService(), MixPanelService(token: Keys.mixPanelToken, loggingEnabled: false)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())
            
        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(), MixPanelService(token: Keys.mixPanelToken)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())
        }
        
        pushManager = PushManager(logManager: logManager)
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
            .environment(LogManager(services: []))
            .environment(PushManager())
    }
}
