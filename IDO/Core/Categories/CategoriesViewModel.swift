//
//  CategoriesViewModel.swift
//  IDO
//
//  Created by George Zorakis on 17/4/25.
//
import SwiftUI


@MainActor
protocol CategoriesInteractor {
    func trackEvent(event: LoggableEvent)
    func schedulePushNotificationsForTheNextWeek()
    func canRequestAuthorization() async -> Bool
    func requestAuthorization() async throws -> Bool
}

extension CoreInteractor: CategoriesInteractor { }


@Observable
@MainActor
class CategoriesViewModel {
    let interactor: CategoriesInteractor
    
    private(set) var categories: [CategoryModel] = CategoryModel.allCategories
    private(set) var showNotificationButton: Bool = false
    
    var path: [CategoryModel] = []
    var showDevSettings: Bool = false
    var showPushNotificationModal: Bool = false
    
    init(interactor: CategoriesInteractor) {
        self.interactor = interactor
    }
    
    var showDevSettingsButton: Bool {
    #if DEV || MOCK
        return true
    #else
        return false
    #endif
    }
    
    func schedulePushNotifications() {
        interactor.schedulePushNotificationsForTheNextWeek()
    }
    
    func handleShowPushNotificationsButton() async {
        showNotificationButton = await interactor.canRequestAuthorization()
    }
    
    func onPushNotificationPressed() {
        showPushNotificationModal = true
        interactor.trackEvent(event: Event.pushNotifsStart)
    }
    
    func onEnablePushNotificationsPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await interactor.requestAuthorization()
            interactor.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationsButton()
        }
    }
    
    func onCancelPushNotificationsPressed() {
        showPushNotificationModal = false
        interactor.trackEvent(event: Event.pushNotifsCancel)
    }
    
    func onDevSettingsPressed() {
        showDevSettings = true
    }
    
    func onCategoryPressed(category: CategoryModel) {
        path.append(category)
        interactor.trackEvent(event: Event.categoryPressed(category: category))
    }
    
    enum Event: LoggableEvent {
        case categoryPressed(category: CategoryModel)
        case pushNotifsStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel
        
        var eventName: String {
            switch self {
            case .categoryPressed:     return "Categories_Category_Pressed"
            case .pushNotifsStart:     return "Categories_PushNotifs_Start"
            case .pushNotifsEnable:    return "Categories_PushNotifs_Enable"
            case .pushNotifsCancel:    return "Categories_PushNotifs_Cancel"

            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .categoryPressed(category: let category):
                return category.eventParameters
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
