//
//  AccountView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI
import SwiftfulUtilities

struct AccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager

    @State private var currentUser: UserModel?
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal: Bool = false
    
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
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.height(300)])

            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .task {
                self.currentUser = userManager.currentUser
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "AccountView")
            .showModal(showModal: $showRatingsModal) {
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
                onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            }
        )
    }
    
    private var nameSection: some View {
        Section {
            ZStack {
                Circle()
                    .overlay {
                        ImageView(imageName: (currentUser?.profileColorHex == "#6482AD" || currentUser?.profileColorHex == "#91BFFF") ? "suit2" : "dress2")
                            .clipShape(Circle())
                            .opacity(0.8)
                    }
                    .overlay {
                        Text(currentUser?.name ?? "")
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
        if isAnonymousUser {
            Button {
                onCreateAccountPressed()
            } label: {
                Text("Save & back-up account")
            }
            .foregroundStyle(.primary)
        } else {
            Button {
                onSignOutPressed()
            } label: {
                Text("Sign Out")
            }
            .foregroundStyle(.primary)
        }
    }
    
    @ViewBuilder
    private var dateSection: some View {
        if let weddingDate = currentUser?.weddingDate, let daysLeft = currentUser?.daysUntilWedding {
            Section("Info") {
                LabeledContent("Wedding Date", value: "\(weddingDate.formatted(date: .long, time: .omitted))")
                LabeledContent("Days left", value: daysLeft < 0 ? "0" : "\(daysLeft)")
            }
        }
    }
    
    private var appInfoSection: some View {
        Section {
            Button {
                onRatingsButtonPressed()
            } label: {
                Text("Rate us on the App Store")
            }
//            .foregroundStyle(.primary)
            LabeledContent("Version", value: Utilities.appVersion ?? "")
            LabeledContent("Build Number", value: Utilities.buildNumber ?? "")
            Button {
                onContactUsPressed()
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
                onDeleteAccountPressed()
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
            }
        }
    }
    
    func onSignOutPressed() {
        logManager.trackEvent(event: Event.signOutPressed)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await dismissScreen()
            } catch {
                logManager.trackEvent(event: Event.signOutFailed(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountPressed)
        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        logManager.trackEvent(event: Event.deleteAccountConfirmed)
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onRatingsButtonPressed() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }
    
    private func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    private func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)

        let email = "zorakisgeorge@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private func onDeleteAccountConfirmed() {
        Task {
            do {
                try await userManager.deleteCurrentUser()
                try await authManager.deleteAccount()
                logManager.deleteUserProfile()
                await dismissScreen()
            } catch {
                logManager.trackEvent(event: Event.deleteAccountFailed(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
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

#Preview("No auth") {
    AccountView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}

#Preview("Anonymous") {
    AccountView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}

#Preview("Not anonymous") {
    AccountView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
