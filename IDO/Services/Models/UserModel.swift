//
//  UserModel.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 15/3/25.
//

import SwiftUI

struct UserModel {
    let userId: String
    let dateCreated: Date?
    let role: String?
    let name: String?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        role: String? = nil,
        name: String? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.role = role
        self.name = name
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else {
            return .accent
        }
        
        return Color(hex: profileColorHex)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(userId: "user1", dateCreated: now, role: "Bride", name: "Yara", didCompleteOnboarding: true, profileColorHex: "#FF8DA1"),
            UserModel(userId: "user2", dateCreated: now.addingTimeInterval(days: -1), role: "Groom", name: "George", didCompleteOnboarding: false, profileColorHex: "#6482AD"),
            UserModel(userId: "user3", dateCreated: now.addingTimeInterval(days: -2), role: "Bride", name: "Maria", didCompleteOnboarding: true, profileColorHex: "#FF8DA1"),
            UserModel(userId: "user4", dateCreated: now.addingTimeInterval(days: -3), role: "Groom", name: "Manos", didCompleteOnboarding: false, profileColorHex: "#6482AD")

        ]
    }
}
