//
//  CreateAccountView.swift
//  IDO
//
//  Created by George Zorakis on 16/3/25.
//
import SwiftUI


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
        viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
    )
    .previewEnvironment()
}
