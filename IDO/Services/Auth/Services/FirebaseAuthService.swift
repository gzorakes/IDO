//
//  FirebaseAuthService.swift
//  IDO
//
//  Created by George Zorakis on 17/3/25.
//

import FirebaseAuth
import SwiftUI
import SignInAppleAsync


struct FirebaseAuthService: AuthService {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            onListenerAttached(listener)
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        let user = UserAuthInfo(user: result.user)
        let isNewUser = result.additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                // try to link to existing anonymous account
                let result = try await user.link(with: credential)
                let user = UserAuthInfo(user: result.user)
                let isNewUser = result.additionalUserInfo?.isNewUser ?? true
                return (user, isNewUser)
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCredential)
                        let user = UserAuthInfo(user: result.user)
                        let isNewUser = result.additionalUserInfo?.isNewUser ?? true
                        return (user, isNewUser)
                    }
                    break
                default:
                    break
                }
            }
        }
        
        // otherwise sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        let user = UserAuthInfo(user: result.user)
        let isNewUser = result.additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        do {
            try await user.delete()
        } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .requiresRecentLogin:
                    // try to reauthenticate user
                    try await reauthenticateUser(error: error)
                    
                    // reauth succesfull
                    return try await user.delete()
                default:
                    break
                }
            }
        
    }
    
    private func reauthenticateUser(error: Error) async throws {
        guard let user = Auth.auth().currentUser, let providerId = user.providerData.first?.providerID else {
            throw AuthError.userNotFound
        }
        
        switch providerId {
        case "apple.com":
            let result = try await signInApple()
            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
        default:
            throw error
        }
        
    }
    
    enum AuthError: LocalizedError {
        case userNotFound
        case reauthAccountChanged
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current authenticated user not found."
            case .reauthAccountChanged:
                return "Reauthentication switched accounts. Please check your account"
            }
        }
    }
}
