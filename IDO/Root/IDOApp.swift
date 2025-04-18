//
//  IDOApp.swift
//  IDO
//
//  Created by George Zorakis on 3/3/25.
//
import SwiftUI
import Firebase
import SwiftfulUtilities


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

/*
 While testing, we dont need to run all
 our dependencies, analytics etc. This way
 we bypass SwiftUI app launch during unit
 testing
 */

struct IDOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: delegate.dependencies.container)))
                .environment(delegate.dependencies.container)
                .environment(delegate.dependencies.logManager)
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









