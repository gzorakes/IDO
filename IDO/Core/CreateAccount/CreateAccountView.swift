//
//  CreateAccountView.swift
//  IDO
//
//  Created by George Zorakis on 16/3/25.
//

import SwiftUI


@Observable
@MainActor
class CreateAccountViewModel {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    
    init(authManager: AuthManager, userManager: UserManager, logManager: LogManager) {
        self.authManager = authManager
        self.userManager = userManager
        self.logManager = logManager
    }
    
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)
        
        var eventName: String {
            switch self {
            case .appleAuthStart:           return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess:         return "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess:    return "CreateAccountView_AppleAuth_LoginSuccess"
            case .appleAuthFail:            return "CreateAccountView_AppleAuth_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func onSignInApplePressed(onDidSignInSuccessfully: @escaping (_ isNewUser: Bool) -> Void) {
        logManager.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))

                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))

                onDidSignInSuccessfully(result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
}


struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAccountViewModel
    
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .whiteOutline,
                cornerRadius: 10
            )
            .frame(height: 55)
            .anyButton(.press) {
                viewModel.onSignInApplePressed(onDidSignInSuccessfully: { isNewUser in
                    onDidSignIn?(isNewUser)
                    dismiss()
                })
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
}

#Preview {
    CreateAccountView(
        viewModel: CreateAccountViewModel(
            authManager: DevPreview.shared.authManager,
            userManager: DevPreview.shared.userManager,
            logManager: DevPreview.shared.logManager
        )
    )
    .previewEnvironment()
//        .environment(UserManager(services: MockUserServices()))
//        .environment(AuthManager(service: MockAuthService()))
}
