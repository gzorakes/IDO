//
//  AccountView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentUser: UserModel?
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?

    
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
        }
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
            LabeledContent("Version", value: Utilities.appVersion ?? "")
            LabeledContent("Build Number", value: Utilities.buildNumber ?? "")
            Button {
                
            } label: {
                Text("Contact us")
            }
            .foregroundStyle(.primary)
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
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await dismissScreen()
            } catch {
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
        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        Task {
            do {
                try await authManager.deleteAccount()
                try await userManager.deleteCurrentUser()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
}

#Preview("No auth") {
    AccountView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(service: MockUserService(user: nil)))
        .environment(AppState())
}

#Preview("Anonymous") {
    AccountView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(service: MockUserService(user: .mock)))
        .environment(AppState())
}

#Preview("Not anonymous") {
    AccountView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(service: MockUserService(user: .mock)))
        .environment(AppState())
}
