//
//  LocalUserPersistence.swift
//  IDO
//
//  Created by George Zorakis on 19/3/25.
//

import SwiftUI

@MainActor
protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
