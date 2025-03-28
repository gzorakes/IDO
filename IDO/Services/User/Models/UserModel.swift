//
//  UserModel.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 15/3/25.
//

import SwiftUI

struct UserModel: Codable {
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let role: String?
    let name: String?
    let weddingDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        role: String? = nil,
        name: String? = nil,
        weddingDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.role = role
        self.name = name
        self.weddingDate = weddingDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case role
        case name
        case weddingDate = "wedding_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.role.rawValue)": role,
            "user_\(CodingKeys.name.rawValue)": name,
            "user_\(CodingKeys.weddingDate.rawValue)": weddingDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.profileColorHex.rawValue)": profileColorHex
        ]
        
        return dict.compactMapValues({ $0 })
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
                creationDate: now,
                role: "Bride",
                name: "Yara",
                weddingDate: now.addingTimeInterval(days: 45),
                didCompleteOnboarding: true,
                profileColorHex: "#FF8DA1"
            ),
            UserModel(
                userId: "user2",
                creationDate: now.addingTimeInterval(days: -1),
                role: "Groom",
                name: "George",
                weddingDate: now.addingTimeInterval(days: 15),
                didCompleteOnboarding: false,
                profileColorHex: "#6482AD"
            ),
            UserModel(
                userId: "user3",
                creationDate: now.addingTimeInterval(days: -2),
                role: "Bride",
                name: "Maria",
                weddingDate: now.addingTimeInterval(days: 66),
                didCompleteOnboarding: true,
                profileColorHex: "#FF8DA1"
            ),
            UserModel(
                userId: "user4",
                creationDate: now.addingTimeInterval(days: -3),
                role: "Groom",
                name: "Manos",
                weddingDate: now.addingTimeInterval(days: 87),
                didCompleteOnboarding: false,
                profileColorHex: "#6482AD"
            )

        ]
    }
}
