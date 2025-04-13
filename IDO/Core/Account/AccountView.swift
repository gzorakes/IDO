//
//  AccountView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI
import SwiftfulUtilities


@Observable
@MainActor
class AccountViewModel {
    let authManager: AuthManager
    let userManager: UserManager
    let logManager: LogManager
    let appState: AppState
    
    var currentUser: UserModel?
    var isAnonymousUser: Bool = false
    
    var showCreateAccountView: Bool = false
    var showAlert: AnyAppAlert?
    var showRatingsModal: Bool = false
    
    init(authManager: AuthManager, userManager: UserManager, logManager: LogManager, appState: AppState) {
        self.authManager = authManager
        self.userManager = userManager
        self.logManager = logManager
        self.appState = appState
    }
    
    func onSignOutPressed(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.signOutPressed)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await dismissScreen(onDismiss: onDismiss)
            } catch {
                logManager.trackEvent(event: Event.signOutFailed(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func dismissScreen(onDismiss: @escaping () async -> Void) async {
        await onDismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteAccountPressed(onDismiss: @Sendable @escaping () async -> Void) async {
        logManager.trackEvent(event: Event.deleteAccountPressed)
        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        Task {
                            self.logManager.trackEvent(event: Event.deleteAccountConfirmed)
                            await self.onDeleteAccountConfirmed(onDismiss: onDismiss)
                        }
                    })
                )
            }
        )
    }
    
    func onDeleteAccountConfirmed(onDismiss: @escaping () async -> Void) async {
        do {
            try await userManager.deleteCurrentUser()
            try await authManager.deleteAccount()
            logManager.deleteUserProfile()
            await dismissScreen(onDismiss: onDismiss)
        } catch {
            logManager.trackEvent(event: Event.deleteAccountFailed(error: error))
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    func onRatingsButtonPressed() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }
    
    func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)

        let email = "zorakisgeorge@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func onCreateAccountPressed() {
        logManager.trackEvent(event: Event.createAccountPressed)
        showCreateAccountView = true
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
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
            .sheet(isPresented: $viewModel.showCreateAccountView, onDismiss: {
                viewModel.setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.height(300)])

            })
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
            .task {
                viewModel.currentUser = viewModel.userManager.currentUser
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
                viewModel.onSignOutPressed(onDismiss: { dismiss() })
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
                Task {
                    await viewModel.onDeleteAccountPressed {
                        await dismiss()
                    }
                }
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview("No auth") {
    AccountView(
        viewModel: AccountViewModel(
            authManager: AuthManager(service: MockAuthService(user: nil)),
            userManager: UserManager(services: MockUserServices(user: nil)),
            logManager: DevPreview.shared.logManager,
            appState: DevPreview.shared.appState
        )
    )
    .previewEnvironment()
}

#Preview("Anonymous") {
    AccountView(
        viewModel: AccountViewModel(
            authManager: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))),
            userManager: UserManager(services: MockUserServices(user: .mock)),
            logManager: DevPreview.shared.logManager,
            appState: DevPreview.shared.appState
        )
    )
    .previewEnvironment()
}

#Preview("Not anonymous") {
    AccountView(
        viewModel: AccountViewModel(
            authManager: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))),
            userManager: UserManager(services: MockUserServices(user: .mock)),
            logManager: DevPreview.shared.logManager,
            appState: DevPreview.shared.appState
        )
    )
    .previewEnvironment()
}
