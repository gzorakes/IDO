//
//  FirebaseUserService.swift
//  IDO
//
//  Created by George Zorakis on 19/3/25.
//

import FirebaseFirestore
import SwiftfulFirestore


struct FirebaseUserService: RemoteUserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String, name: String, weddingDate: Date) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex,
            UserModel.CodingKeys.name.rawValue: name,
            UserModel.CodingKeys.weddingDate.rawValue: weddingDate,
        ])
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}
