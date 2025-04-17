//
//  AccountViewModel.swift
//  IDO
//
//  Created by George Zorakis on 17/4/25.
//
import SwiftUI
import SwiftfulUtilities

@MainActor
protocol AccountInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func authSignOut() throws
    func deleteAccount() async throws
    func userSignOut()
    func deleteCurrentUser() async throws
    func trackEvent(event: LoggableEvent)
    func deleteUserProfile()
}

@MainActor
struct ProdAccountInteractor: AccountInteractor {
    let authManager: AuthManager
    let userManager: UserManager
    let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func authSignOut() throws {
        try authManager.signOut()
    }
    
    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }
    
    func userSignOut() {
        userManager.signOut()
    }
    
    func deleteCurrentUser() async throws {
        try await userManager.deleteCurrentUser()
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
}


@Observable
@MainActor
class AccountViewModel {
    
    let interactor: AccountInteractor
    let container: DependencyContainer
//    let container: DependencyContainer
//    let authManager: AuthManager
//    let userManager: UserManager
//    let logManager: LogManager
    
    private(set) var isAnonymousUser: Bool = false
    
    var currentUser: UserModel?
    var showCreateAccountView: Bool = false
    var showAlert: AnyAppAlert?
    var showRatingsModal: Bool = false
    
    init(interactor: AccountInteractor, container: DependencyContainer) {
        self.interactor = interactor
        self.container = container
    }
    
    
    func onSignOutPressed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: Event.signOutPressed)
        Task {
            do {
                try interactor.authSignOut()
                interactor.userSignOut()
                await onDismiss()
            } catch {
                interactor.trackEvent(event: Event.signOutFailed(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onDeleteAccountPressed(onDismiss: @Sendable @escaping () async -> Void) {
        interactor.trackEvent(event: Event.deleteAccountPressed)
        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        self.interactor.trackEvent(event: Event.deleteAccountConfirmed)
                        self.onDeleteAccountConfirmed(onDismiss: onDismiss)
                    })
                )
            }
        )
    }
    
    func onDeleteAccountConfirmed(onDismiss: @escaping () async -> Void) {
        Task {
            do {
                try await interactor.deleteCurrentUser()
                try await interactor.deleteAccount()
                interactor.deleteUserProfile()
                await onDismiss()
            } catch {
                interactor.trackEvent(event: Event.deleteAccountFailed(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onRatingsButtonPressed() {
        interactor.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }
    
    func onEnjoyingAppYesPressed() {
        interactor.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    func onEnjoyingAppNoPressed() {
        interactor.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    func onContactUsPressed() {
        interactor.trackEvent(event: Event.contactUsPressed)

        let email = "zorakisgeorge@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func onCreateAccountPressed() {
        interactor.trackEvent(event: Event.createAccountPressed)
        showCreateAccountView = true
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.auth?.isAnonymous == true
    }
    
    enum Event: LoggableEvent {
        case createAccountPressed
        case signOutPressed
        case signOutFailed(error: Error)
        case deleteAccountPressed
        case deleteAccountConfirmed
        case deleteAccountFailed(error: Error)
        case contactUsPressed
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed
        
        var eventName: String {
            switch self {
            case .createAccountPressed:   return "Account_CreateAccountPressed"
            case .signOutPressed:         return "Account_SignOutPressed"
            case .signOutFailed:          return "Account_SignOutFailed"
            case .deleteAccountPressed:   return "Account_DeletePressed"
            case .deleteAccountConfirmed: return "Account_DeleteConfirmed"
            case .deleteAccountFailed:    return "Account_DeleteFailed"
            case .contactUsPressed:       return "Account_ContactUsPressed"
            case .ratingsPressed:         return "Account_RatingsPressed"
            case .ratingsYesPressed:      return "Account_RatingsYesPressed"
            case .ratingsNoPressed:       return "Account_RatingsNoPressed"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .signOutFailed(let error),
                    .deleteAccountFailed(let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFailed,
                    .deleteAccountFailed:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
