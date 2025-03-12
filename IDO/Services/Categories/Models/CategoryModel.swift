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
        case .hall: return "eventhall"
        case .church: return "church"
        case .invitations: return "invitation"
        case .flowers: return "flowers"
        case .decoration: return "decoration"
        case .dress: return "dress"
        case .costume: return "suit"
        case .music: return "music"
        case .car: return "car"
        case .rings: return "rings"
        case .notes: return "notes"
        case .guests: return "guests"
        }
    }
    
    static let allCategories: [CategoryModel] = CategoryModel.allCases
}
