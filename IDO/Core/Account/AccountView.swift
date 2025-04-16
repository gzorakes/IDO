//
//  AccountView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
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


struct AccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State var viewModel: AccountViewModel

    var body: some View {
        NavigationStack {
            List {
                nameSection
                saveSection
                dateSection
                appInfoSection
                deleteSection
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(
                isPresented: $viewModel.showCreateAccountView,
                onDismiss: {
                    viewModel.setAnonymousAccountStatus()
                },
                content: {
                    CreateAccountView(
                        viewModel: CreateAccountViewModel(container: viewModel.container)
                    )
                    .presentationDetents([.height(300)])

            })
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
            .task {
                viewModel.currentUser = viewModel.interactor.currentUser
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "AccountView")
            .showModal(showModal: $viewModel.showRatingsModal) {
                ratingsModal
            }
        }
    }
    
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying IDO App?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                viewModel.onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                viewModel.onEnjoyingAppNoPressed()
            }
        )
    }
    
    private var nameSection: some View {
        Section {
            ZStack {
                Circle()
                    .overlay {
                        ImageView(imageName: (viewModel.currentUser?.profileColorHex == "#6482AD" || viewModel.currentUser?.profileColorHex == "#91BFFF") ? "suit2" : "dress2")
                            .clipShape(Circle())
                            .opacity(0.8)
                    }
                    .overlay {
                        Text(viewModel.currentUser?.name ?? "")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        .black.opacity(0),
                                        .black.opacity(0.6),
                                        .black.opacity(0.7),
                                        .black.opacity(0.6),
                                        .black.opacity(0)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    }
            }
        }
        .frame(width: 100, height: 100)
        .frame(maxWidth: .infinity)
        .removeListRowFormatting()
    }
        
    
    private var saveSection: some View {
        if viewModel.isAnonymousUser {
            Button {
                viewModel.onCreateAccountPressed()
            } label: {
                Text("Save & back-up account")
            }
            .foregroundStyle(.primary)
        } else {
            Button {
                viewModel.onSignOutPressed(onDismiss: {
                    await dismissScreen()
                })
            } label: {
                Text("Sign Out")
            }
            .foregroundStyle(.primary)
        }
    }
    
    @ViewBuilder
    private var dateSection: some View {
        if let weddingDate = viewModel.currentUser?.weddingDate, let daysLeft = viewModel.currentUser?.daysUntilWedding {
            Section("Info") {
                LabeledContent("Wedding Date", value: "\(weddingDate.formatted(date: .long, time: .omitted))")
                LabeledContent("Days left", value: daysLeft < 0 ? "0" : "\(daysLeft)")
            }
        }
    }
    
    private var appInfoSection: some View {
        Section {
            Button {
                viewModel.onRatingsButtonPressed()
            } label: {
                Text("Rate us on the App Store")
            }
//            .foregroundStyle(.primary)
            LabeledContent("Version", value: Utilities.appVersion ?? "")
            LabeledContent("Build Number", value: Utilities.buildNumber ?? "")
            Button {
                viewModel.onContactUsPressed()
            } label: {
                Text("Contact us")
            }
//            .foregroundStyle(.primary)
        } header: {
            Text("Application")
        } footer: {
            Text("Created by George Zorakis")
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button {
                viewModel.onDeleteAccountPressed(onDismiss: {
                    await dismissScreen()
                })
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
            }
        }
    }
        
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    container.register(LogManager.self, service: LogManager(services: []))
    
    return AccountView(
        viewModel: AccountViewModel(
            interactor: ProdAccountInteractor(container: container),
            container: container
        )
    )
    .previewEnvironment()
}

#Preview("No auth") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(LogManager.self, service: LogManager(services: []))
    
    return AccountView(
        viewModel: AccountViewModel(
            interactor: ProdAccountInteractor(container: container),
            container: container
        )
    )
    .previewEnvironment()
}

#Preview("Not anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    container.register(LogManager.self, service: LogManager(services: []))
    
    return AccountView(
        viewModel: AccountViewModel(
            interactor: ProdAccountInteractor(container: container),
            container: container
        )
    )
    .previewEnvironment()
}
