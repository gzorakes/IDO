//
//  MockUserService.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 19/3/25.
//

import SwiftUI


struct MockUserService: RemoteUserService {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String, name: String, weddingDate: Date) async throws {
        
    }
}
