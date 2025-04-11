//
//  MockUserService.swift
//  IDO
//
//  Created by George Zorakis on 19/3/25.
//

import SwiftUI

@MainActor
class MockUserService: RemoteUserService {
    
    @Published var currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
                        
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        currentUser = nil
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String, name: String, weddingDate: Date) async throws {
        guard let currentUser else {
            throw URLError(.unknown)
        }
        
        self.currentUser = UserModel(
            userId: currentUser.userId,
            email: currentUser.email,
            isAnonymous: currentUser.isAnonymous,
            creationDate: currentUser.creationDate,
            creationVersion: currentUser.creationVersion,
            lastSignInDate: currentUser.lastSignInDate,
            role: currentUser.role,
            name: currentUser.name,
            weddingDate: currentUser.weddingDate,
            didCompleteOnboarding: true,
            profileColorHex: profileColorHex
        )
        
    }
}
