//
//  Error+EXT.swift
//  IDO
//
//  Created by George Zorakis on 29/3/25.
//

import Foundation

extension Error {
    
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
