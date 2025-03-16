//
//  Utilities.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 16/3/25.
//

import Foundation

public struct Utilities {
    
    public static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var buildNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
