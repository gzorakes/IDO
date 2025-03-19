//
//  LocalUserPersistence.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 19/3/25.
//

import SwiftUI

protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
