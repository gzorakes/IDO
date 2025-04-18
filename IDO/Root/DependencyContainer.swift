//
//  DependencyContainer.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI


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

/*
 almost same like @Environment implementation,
 where we register dependencies in the root
 of our app and then we pull whatever dependency
 we need across the entire app
*/
