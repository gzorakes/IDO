//
//  CoreInteractor.swift
//  IDO
//
//  Created by George Zorakis on 17/4/25.
//
import SwiftUI


@MainActor
struct CoreInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let todoManager: TodoManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let appState: AppState

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.todoManager = container.resolve(TodoManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.appState = container.resolve(AppState.self)!
    }
    
    // MARK: AppState
    var showTabBar: Bool {
        appState.showTabBar
    }
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    // MARK: AuthManager
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }
    
    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }
    
    // MARK: UserManager
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String, name: String, weddingDate: Date) async throws {
        try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: profileColorHex, name: name, weddingDate: weddingDate)
    }
    
    func deleteCurrentUser() async throws {
        try await userManager.deleteCurrentUser()
    }
    
    // MARK: AIManager
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    // MARK: TodoManager
    func createTodo(todoItem: TodoItemModel) async throws {
        try await todoManager.createTodo(todoItem: todoItem)
    }
    
    func getTodos() async throws -> [TodoItemModel] {
        try await todoManager.getTodos()
    }
    
    func getTodosForCategory(category: String) async throws -> [TodoItemModel] {
        try await todoManager.getTodosForCategory(category: category)
    }
    
    func getTodosForAuthor(userId: String, category: String) async throws -> [TodoItemModel] {
        try await todoManager.getTodosForAuthor(userId: userId, category: category)
    }
    
    func updateTodo(todoItem: TodoItemModel) async throws {
        try await todoManager.updateTodo(todoItem: todoItem)
    }
    
    func deleteTodo(todoId: String) async throws {
        try await todoManager.deleteTodo(todoId: todoId)
    }
    
    // MARK: LogManager
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    
    func trackEvent(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackScreenEvent(event: event)
    }
    
    // MARK: PushManager
    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    // MARK: SHARED
    func signOut() throws {
        try authManager.signOut()
        userManager.signOut()
    }
    
}
