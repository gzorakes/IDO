//
//  LogService.swift
//  IDO
//
//  Created by George Zorakis on 28/3/25.
//

import SwiftUI

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String : Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
