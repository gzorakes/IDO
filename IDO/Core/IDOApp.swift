//
//  IDOApp.swift
//  IDO
//
//  Created by George Zorakis on 3/3/25.
//

import SwiftUI
import Firebase
import SwiftfulUtilities



/*
 While testing, we dont need to run all
 our dependencies, analytics etc. This way
 we bypass SwiftUI app launch during unit
 testing
 */
@main
struct AppEntryPoint {
    
    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            IDOApp.main()
        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing.")
        }
    }
}


struct IDOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.container)
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
    
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        if Utilities.isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            UserDefaults.showTabbarView = isSignedIn
            config = .mock(isSignedIn: isSignedIn)
        }
        
        config.configure()
        dependencies = Dependencies(config: config)
        return true
    }
}

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

/*
 almost same like @Environment implementation,
 where we register dependencies in the root
 of our app and then we pull whatever dependency
 we need across the entire app
*/
@Observable
@MainActor
class DependencyContainer {
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}


@MainActor
struct Dependencies {
    let container: DependencyContainer
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
                ConsoleService(printParameters: false)/*, FirebaseAnalyticsService()*/, MixPanelService(token: Keys.mixPanelToken, loggingEnabled: false)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())
            
        case .prod:
            logManager = LogManager(services: [
                /*FirebaseAnalyticsService(), */MixPanelService(token: Keys.mixPanelToken)
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            todoManager = TodoManager(service: FirebaseTodoService())
        }
        
        pushManager = PushManager(logManager: logManager)
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        self.container = container
    }
}


extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(DevPreview.shared.container)
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(TodoManager(service: MockTodoService()))
            .environment(AppState())
            .environment(AIManager(service: MockAIService()))
            .environment(LogManager(services: []))
            .environment(PushManager())
    }
}


@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    let container: DependencyContainer
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let todoManager: TodoManager
    let logManager: LogManager
    let pushManager: PushManager
    
    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.aiManager = AIManager(service: MockAIService())
        self.todoManager = TodoManager(service: MockTodoService())
        self.logManager = LogManager(services: [])
        self.pushManager = PushManager()
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(TodoManager.self, service: todoManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        self.container = container
    }
}
