//
//  AppDelegate.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI
import Firebase


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
            config = .mock(isSignedIn: isSignedIn)
        }
        
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
