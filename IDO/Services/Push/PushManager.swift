//
//  PushManager.swift
//  IDO
//
//  Created by George Zorakis on 31/3/25.
//

import Foundation
import SwiftfulUtilities

@MainActor
@Observable
class PushManager {
    
    private let logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_is_authorized:": isAuthorized], isHighPriority: true)
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                // tomorrow
                try await scheduleNotification(
                    title: "Hey you! Ready to get married?",
                    subtitle: "Open IDO to plan everything!",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )
                
                // in 3 days
                try await scheduleNotification(
                    title: "How’s the planning going?",
                    subtitle: "IDO’s here to keep things stress-free",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                
                // in 5 days
                try await scheduleNotification(
                    title: "Still on track for the big day?",
                    subtitle: "IDO can help if you're falling behind.",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                
                logManager?.trackEvent(event: Event.weekSchedulesSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekSchedulesFail(error: error))
            }
        }
    }
    
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    enum Event: LoggableEvent {
        case weekSchedulesSuccess
        case weekSchedulesFail(error: Error)
        
        var eventName: String {
            switch self {
            case .weekSchedulesSuccess:  return "PushMan_WeekSchedule_Success"
            case .weekSchedulesFail:     return "PushMan_WeekSchedule_Fail"

            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .weekSchedulesFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .weekSchedulesFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
