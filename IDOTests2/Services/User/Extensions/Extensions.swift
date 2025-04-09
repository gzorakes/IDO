//
//  Extensions.swift
//  IDO
//
//  Created by George Zorakis on 9/4/25.
//

import Foundation

extension String {
    static var random: String {
        UUID().uuidString
    }

    static func randomEmail() -> String {
        "\(String.random.prefix(8))@example.com"
    }
}

extension Bool {
    static var random: Bool {
        Bool.random()
    }
}

extension Date {

    static var random: Date {
        Calendar.current.date(byAdding: .day, value: Int.random(in: -500...500), to: .now) ?? Date()
    }
    
    func truncatedToSeconds() -> Date {
        let time = Int(timeIntervalSince1970)
        return Date(timeIntervalSince1970: TimeInterval(time))
    }

    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}

