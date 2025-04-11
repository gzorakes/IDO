//
//  RemoteUserService.swift
//  IDO
//
//  Created by George Zorakis on 19/3/25.
//

import SwiftUI

@MainActor
protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String, name: String, weddingDate: Date) async throws
}
