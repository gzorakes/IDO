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
    let weddingDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        role: String? = nil,
        name: String? = nil,
        weddingDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.role = role
        self.name = name
        self.weddingDate  = weddingDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else { return .accent }
        return Color(hex: profileColorHex)
    }
    
    var daysUntilWedding: Int? {
        guard let weddingDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weddingDay = calendar.startOfDay(for: weddingDate)
        return calendar.dateComponents([.day], from: today, to: weddingDay).day
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "user1",
                dateCreated: now,
                role: "Bride",
                name: "Yara",
                weddingDate: now.addingTimeInterval(days: 45),
                didCompleteOnboarding: true,
                profileColorHex: "#FF8DA1"
            ),
            UserModel(
                userId: "user2",
                dateCreated: now.addingTimeInterval(days: -1),
                role: "Groom",
                name: "George",
                weddingDate: now.addingTimeInterval(days: 15),
                didCompleteOnboarding: false,
                profileColorHex: "#6482AD"
            ),
            UserModel(
                userId: "user3",
                dateCreated: now.addingTimeInterval(days: -2),
                role: "Bride",
                name: "Maria",
                weddingDate: now.addingTimeInterval(days: 66),
                didCompleteOnboarding: true,
                profileColorHex: "#FF8DA1"
            ),
            UserModel(
                userId: "user4",
                dateCreated: now.addingTimeInterval(days: -3),
                role: "Groom",
                name: "Manos",
                weddingDate: now.addingTimeInterval(days: 87),
                didCompleteOnboarding: false,
                profileColorHex: "#6482AD"
            )

        ]
    }
}
