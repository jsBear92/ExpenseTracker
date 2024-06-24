//
//  ExpenseView.swift
//  ExpenseTracker
//
//  Created by Jaeseong Jeong on 24/6/2024.
//

import SwiftUI
import SwiftData

struct ExpenseView: View {
    @Binding var currentTab: String
    // Grouped Expenses Properties
    @Query(sort: [SortDescriptor(\Expense.date, order: .reverse)], animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    // Grouped Expenses
    // This will also be used for filtering purpose
    @State private var groupedExpenses: [GroupedExpense] = []
    @State private var originalGroupedExpenses: [GroupedExpense] = []
    @State private var addExpense: Bool = false
    // Search Text
    @State private var searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedExpenses) { group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            // Card View
                            ExpenseCardView(expense: expense)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    deleteButton(for: expense, in: group)
                                }
                        }
                    }
                    
                }
            }
            .navigationTitle("Expenses")
            // Search Bar
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("Search"))
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            // New Expense Add Button
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    
                }
            }
        }
        .onChange(of: searchText, initial: false) { oldValue, newValue in
            if !newValue.isEmpty {
                filterExpenses(newValue)
            } else {
                groupedExpenses = originalGroupedExpenses
            }
        }
        .onChange(of: allExpenses, initial: true) { oldValue, newValue in
            if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab == "Categories" {
                createGroupedExpenses(newValue)
            }
        }
        .sheet(isPresented: $addExpense, content: {
            AddExpenseView()
                .interactiveDismissDisabled()
        })
    }
    
    // Filtering Expense
    func filterExpenses(_ text: String) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filteredExpenses = originalGroupedExpenses.compactMap { group -> GroupedExpense? in
                let expenses = group.expenses.filter({ $0.title.lowercased().contains(query) })
                if expenses.isEmpty {
                    return nil
                }
                return .init(date: group.date, expenses: expenses)
            }
            
            await MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }
    
    @ViewBuilder
    private func deleteButton(for expense: Expense, in group: GroupedExpense) -> some View {
        Button {
            deleteExpense(expense, in: group)
        } label: {
            Image(systemName: "trash")
        }
        .tint(.red)
    }
    
    private func deleteExpense(_ expense: Expense, in group: GroupedExpense) {
        // Deleting Data
        context.delete(expense)
        withAnimation {
            // Find the index of the group in groupedExpenses
            if let groupIndex = groupedExpenses.firstIndex(where: { $0.id == group.id }) {
                // Remove the expense from the group
                groupedExpenses[groupIndex].expenses.removeAll(where: { $0.id == expense.id })
                // Remove the group if no expenses are present
                if groupedExpenses[groupIndex].expenses.isEmpty {
                    groupedExpenses.remove(at: groupIndex)
                }
            }
        }
    }
    
    // Creating Grouped Expenses (Grouping By Date)
    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
                
                return dateComponents
            }
            
            // Sorting Dictionary in Descending Order
            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()
                
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            // Adding to the Grouped Expenses Array
            // UI Must be Updated on Main Thread
            await MainActor.run {
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)
                })
                originalGroupedExpenses = groupedExpenses
            }
        }
    }
}

//#Preview {
//    ExpenseView()
//}
