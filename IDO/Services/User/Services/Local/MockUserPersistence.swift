//
//  MockUserPersistence.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 19/3/25.
//

import Foundation

struct MockUserPersistence: LocalUserPersistence {
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        
    }
}
