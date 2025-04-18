//
//  AccountViewTests.swift
//  IDOTests2
//
//  Created by George Zorakis on 16/4/25.
//

import Testing
import SwiftUI
@testable import IDO

@MainActor
struct AccountViewTests {

    @Test("Initialization with Authenticated User")
    func testUserIsAuthenticated() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        let logManager = LogManager(services: [MockLogService()])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = AccountViewModel(interactor: CoreInteractor(container: container))
        
        // When
        viewModel.setAnonymousAccountStatus()
        
        // Then
        #expect(viewModel.currentUser?.userId != mockUser.userId)
    }
    
    @Test("Initialization with Anonymous User")
        func testUserIsAnonymous() async throws {
            let container = DependencyContainer()
            let authManager = AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true)))
            let userManager = UserManager(services: MockUserServices())
            let logManager = LogManager(services: [MockLogService()])

            container.register(AuthManager.self, service: authManager)
            container.register(UserManager.self, service: userManager)
            container.register(LogManager.self, service: logManager)

            let viewModel = AccountViewModel(interactor: CoreInteractor(container: container))
            viewModel.setAnonymousAccountStatus()

            #expect(viewModel.isAnonymousUser == true)
        }

}
