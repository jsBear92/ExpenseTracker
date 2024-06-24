//
//  Category.swift
//  ExpenseTracker
//
//  Created by Jaeseong Jeong on 24/6/2024.
//

import SwiftUI
import SwiftData

@Model
class Category {
    var categoryName: String
    // Category Expenses
    @Relationship(deleteRule: .cascade, inverse: \Expense.category)
    var expenses: [Expense]?
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
}
