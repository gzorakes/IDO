//
//  DevSettingsViewModel.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI


@MainActor
protocol DevSettingsInteractor {
    func trackEvent(event: LoggableEvent)
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
}

extension CoreInteractor: DevSettingsInteractor { }

@Observable
@MainActor
class DevSettingsViewModel {
    private let interactor: DevSettingsInteractor
    
    var authData: [(key: String, value: Any)] {
        interactor.auth?.eventParameters.map({ (key: $0, value: $1) }) ?? []
    }
    
    var userData: [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.map({ (key: $0, value: $1) }) ?? []
    }
    
    var utilitiesData: [(key: String, value: Any)] {
        Utilities.eventParameters.map({ (key: $0, value: $1) })
    }
    
    init(interactor: DevSettingsInteractor) {
        self.interactor = interactor
    }
}
