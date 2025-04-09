//
//  UserModelTests.swift
//  IDOTests2
//
//  Created by George Zorakis on 9/4/25.
//

import Testing
import SwiftUI
@testable import IDO

struct UserModelTests {

    @Test("UserModel Initialization with All Values")
    func testInitializationWithAllValues() async throws {
        let userId = String.random
        let email = String.randomEmail()
        let isAnonymous = Bool.random
        let creationDate = Date.random
        let creationVersion = String.random
        let lastSignInDate = Date.random
        let role = "Bride"
        let name = "Maria"
        let weddingDate = Date().addingDays(20)
        let didCompleteOnboarding = Bool.random
        let profileColorHex = "#FF8DA1"

        try await Task.sleep(for: .seconds(10))
        let user = UserModel(
            userId: userId,
            email: email,
            isAnonymous: isAnonymous,
            creationDate: creationDate,
            creationVersion: creationVersion,
            lastSignInDate: lastSignInDate,
            role: role,
            name: name,
            weddingDate: weddingDate,
            didCompleteOnboarding: didCompleteOnboarding,
            profileColorHex: profileColorHex
        )

        #expect(user.userId == userId)
        #expect(user.email == email)
        #expect(user.isAnonymous == isAnonymous)
        #expect(user.creationDate == creationDate)
        #expect(user.creationVersion == creationVersion)
        #expect(user.lastSignInDate == lastSignInDate)
        #expect(user.role == role)
        #expect(user.name == name)
        #expect(user.weddingDate == weddingDate)
        #expect(user.didCompleteOnboarding == didCompleteOnboarding)
        #expect(user.profileColorHex == profileColorHex)
    }

    @Test("UserModel Event Parameters")
    func testEventParameters() async throws {
        let user = UserModel(
            userId: .random,
            email: .randomEmail(),
            isAnonymous: .random,
            creationDate: .random,
            creationVersion: .random,
            lastSignInDate: .random,
            role: "Bride",
            name: "Sophia",
            weddingDate: .random,
            didCompleteOnboarding: .random,
            profileColorHex: "#FF8DA1"
        )

        let params = user.eventParameters

        #expect(params["user_user_id"] as? String == user.userId)
        #expect(params["user_email"] as? String == user.email)
        #expect(params["user_is_anonymous"] as? Bool == user.isAnonymous)
        #expect(params["user_creation_date"] as? Date == user.creationDate)
        #expect(params["user_creation_version"] as? String == user.creationVersion)
        #expect(params["user_last_sign_in_date"] as? Date == user.lastSignInDate)
        #expect(params["user_role"] as? String == user.role)
        #expect(params["user_name"] as? String == user.name)
        #expect(params["user_wedding_date"] as? Date == user.weddingDate)
        #expect(params["user_did_complete_onboarding"] as? Bool == user.didCompleteOnboarding)
        #expect(params["user_profile_color_hex"] as? String == user.profileColorHex)
    }

    @Test("UserModel Profile Color Should Default to Accent")
    func testProfileColorFallbackToAccent() async throws {
        let user = UserModel(userId: "test_no_color")
        #expect(user.profileColorCalculated == Color.accent)
    }

    @Test("UserModel Profile Color Should Convert Hex Correctly")
    func testProfileColorFromHex() async throws {
        let user = UserModel(userId: "test_color", profileColorHex: "#6482AD")
        #expect(user.profileColorCalculated == Color(hex: "#6482AD"))
    }

    @Test("UserModel Days Until Wedding Calculation")
    func testDaysUntilWedding() async throws {
        let futureWedding = Date().addingDays(30)
        let user = UserModel(userId: "bride", weddingDate: futureWedding)
        #expect(user.daysUntilWedding == 30)
    }

    @Test("UserModel Codable Conformance")
    func testCodableRoundTrip() async throws {
        let userId = String.random
        let email = String.randomEmail()
        let isAnonymous = Bool.random
        let creationDate = Date.random
        let creationVersion = String.random
        let lastSignInDate = Date.random
        let role = "Groom"
        let name = "Leo"
        let weddingDate = Date.random
        let didCompleteOnboarding = Bool.random
        let profileColorHex = "#FF8DA1"

        let original = UserModel(
            userId: userId,
            email: email,
            isAnonymous: isAnonymous,
            creationDate: creationDate,
            creationVersion: creationVersion,
            lastSignInDate: lastSignInDate,
            role: role,
            name: name,
            weddingDate: weddingDate,
            didCompleteOnboarding: didCompleteOnboarding,
            profileColorHex: profileColorHex
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserModel.self, from: data)

        #expect(decoded.userId == original.userId)
        #expect(decoded.email == original.email)
        #expect(decoded.isAnonymous == original.isAnonymous)
        #expect(decoded.creationDate?.truncatedToSeconds() == original.creationDate?.truncatedToSeconds())
        #expect(decoded.creationVersion == original.creationVersion)
        #expect(decoded.lastSignInDate?.truncatedToSeconds() == original.lastSignInDate?.truncatedToSeconds())
        #expect(decoded.role == original.role)
        #expect(decoded.name == original.name)
        #expect(decoded.weddingDate?.truncatedToSeconds() == original.weddingDate?.truncatedToSeconds())
        #expect(decoded.didCompleteOnboarding == original.didCompleteOnboarding)
        #expect(decoded.profileColorHex == original.profileColorHex)
    }

    @Test("UserModel Init from UserAuthInfo")
    func testInitFromAuthInfo() async throws {
        let auth = UserAuthInfo(
            uid: "auth_user",
            email: "auth@example.com",
            isAnonymous: true,
            creationDate: .random,
            lastSignInDate: .random
        )

        let user = UserModel(auth: auth, creationVersion: "3.2.1")

        #expect(user.userId == auth.uid)
        #expect(user.email == auth.email)
        #expect(user.isAnonymous == auth.isAnonymous)
        #expect(user.creationDate == auth.creationDate)
        #expect(user.lastSignInDate == auth.lastSignInDate)
        #expect(user.creationVersion == "3.2.1")
    }
}

