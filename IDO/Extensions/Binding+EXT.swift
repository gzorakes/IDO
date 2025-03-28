//
//  Binding+EXT.swift
//  IDO
//
//  Created by George Zorakis on 18/3/25.
//

import SwiftUI

extension Binding where Value == Bool {
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}
