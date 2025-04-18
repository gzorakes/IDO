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
    @Environment(DependencyContainer.self) private var container
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
                        viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container))
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
    }
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    container.register(LogManager.self, service: LogManager(services: []))
    
    return AccountView(
        viewModel: AccountViewModel(
            interactor: CoreInteractor(container: container)
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
            interactor: CoreInteractor(container: container)
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
            interactor: CoreInteractor(container: container)
        )
    )
    .previewEnvironment()
}
