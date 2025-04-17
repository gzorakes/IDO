//
//  WelcomeViewModel.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: WelcomeInteractor { }

@Observable
@MainActor
class WelcomeViewModel {
    private let interactor: WelcomeInteractor
    
    var showSignInView: Bool = false
    
    init(interactor: WelcomeInteractor) {
        self.interactor = interactor
    }
    
    func handleDidSignIn(isNewUser: Bool, onShowTabBarView: () -> Void) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // do nothing, user goes through onboarding
        } else {
            // push into tabbar view
            onShowTabBarView()
        }
    }
    
    func onSignInPressed() {
        showSignInView = true
        interactor.trackEvent(event: Event.signInPressed)
    }
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:        return "WelcomeView_DidSignIn"
            case .signInPressed:    return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case.didSignIn(isNewUser: let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}

