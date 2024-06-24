//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Jaeseong Jeong on 24/6/2024.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        // Setting Up the container
        .modelContainer(for: [Expense.self, Category.self])
    }
}
