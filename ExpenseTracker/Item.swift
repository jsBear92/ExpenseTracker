//
//  Item.swift
//  ExpenseTracker
//
//  Created by Jaeseong Jeong on 24/6/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
