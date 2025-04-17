//
//  WelcomeView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//
import SwiftUI

struct WelcomeView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: WelcomeViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8.0) {
                Image("welcomephoto")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
                    .fontDesign(.rounded)
                
                ctaButtons
                    .padding(16)
                
                policyLinks
            }
        }
        .screenAppearAnalytics(name: "WelcomeView")
        .sheet(isPresented: $viewModel.showSignInView) {
            CreateAccountView(
                viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container)),
                title: "Sign in",
                subtitle: "Connect to an existing account",
                onDidSignIn: { isNewUser in
                    viewModel.handleDidSignIn(isNewUser: isNewUser, onShowTabBarView: {
                        appState.updateViewState(showTabBarView: true)
                    })
                }
            )
                .presentationDetents([.height(300)])
        }
    }
    
    private var titleSection: some View {
        VStack {
            Text("Yes I Do! 💍")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            
            Text("by George Zorakis")
                .font(.caption)
                .foregroundStyle(.secondary)
            
        }
    }
    
    private var ctaButtons: some View {
        VStack {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    viewModel.onSignInPressed()
                }
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 26)
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceUrl)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.secondary)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Privacy Policy")
            }
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
