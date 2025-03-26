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
        
        dependencies = Dependencies()
        return true
    }
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let todoManager: TodoManager
    
    init() {
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        aiManager = AIManager(service: OpenAIService())
        todoManager = TodoManager(service: FirebaseTodoService())
    }
}
