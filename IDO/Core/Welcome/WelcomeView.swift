//
//  WelcomeView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(AppState.self) private var root
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(DependencyContainer.self) private var container
    
    @State var imageName: String = Constants.randomImage
    @State private var showSignInView: Bool = false

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
        .sheet(isPresented: $showSignInView) {
            CreateAccountView(
                viewModel: CreateAccountViewModel(container: container),
                title: "Sign in",
                subtitle: "Connect to an existing account",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
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
                    onSignInPressed()
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
    
    
    
    private func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // do nothing, user goes through onboarding
        } else {
            // push into tabbar view
            root.updateViewState(showTabBarView: true)
        }
    }
    
    private func onSignInPressed() {
        showSignInView = true
        logManager.trackEvent(event: Event.signInPressed)
    }
}

#Preview {
    WelcomeView()
        .previewEnvironment()
}
