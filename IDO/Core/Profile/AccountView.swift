//
//  AccountView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(AppState.self) private var appState
    @State private var currentUser: UserModel? = .mocks[1]
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    
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
            .sheet(isPresented: $showCreateAccountView) {
                CreateAccountView()
                    .presentationDetents([.height(300)])
            }
        }
    }
    
    private var nameSection: some View {
        Section {
            ZStack {
                Circle()
                    .overlay {
                        ImageView(imageName: currentUser?.role == "Groom" ? "suit2" : "dress2")
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
                // delete logic
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
            }
        }
    }
    
    func onSignOutPressed() {
        appState.updateViewState(showTabBarView: false)
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
    }
}

#Preview {
    AccountView()
        .environment(AppState())
}
