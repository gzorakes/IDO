//
//  CategoryModel.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 8/3/25.
//

import SwiftUI

enum CategoryModel: String, CaseIterable, Identifiable {
    case hall, church, invitations, flowers, decoration, dress, costume, music, car, rings, notes, guests
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .hall: return "Event Hall"
        case .church: return "Church"
        case .invitations: return "Invitations"
        case .flowers: return "Flowers"
        case .decoration: return "Decoration"
        case .dress: return "Dress"
        case .costume: return "Suit"
        case .music: return "Music"
        case .car: return "Car"
        case .rings: return "Rings"
        case .notes: return "Notes"
        case .guests: return "Guests"
        }
    }
    
    var imageName: String {
        switch self {
        case .hall: return "eventhall2"
        case .church: return "church2"
        case .invitations: return "invitation2"
        case .flowers: return "flowers2"
        case .decoration: return "decoration2"
        case .dress: return "dress2"
        case .costume: return "suit2"
        case .music: return "music2"
        case .car: return "car2"
        case .rings: return "rings2"
        case .notes: return "notes2"
        case .guests: return "guests2"
        }
    }
    
    static let allCategories: [CategoryModel] = CategoryModel.allCases
}
