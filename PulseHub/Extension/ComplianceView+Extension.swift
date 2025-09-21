//
//  ComplianceView+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/6/25.
//

import Foundation

extension DataModel {

    /// Creates and saves a new `ComplianceItem` with the provided details.
    ///
    /// - Parameters:
    ///   - title: The title of the compliance item. Leading and trailing whitespace and newlines are trimmed.
    ///   - detail: Additional detail or notes for the item. If empty, it will be set to `nil`.
    ///   - dueDate: The due date for the compliance item.
    ///   - priority: The priority level assigned to the item.
    ///
    /// The new item will be assigned to the currently selected category, or to a default "General" category if none is selected.
    /// After setting its properties, the item is saved using the model's `save(_:)` method.
    func saveItem(title: String, detail: String, dueDate: Date, priority: Priority) {
        let item = ComplianceItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,  // This can be nil, which is fine
            detail: detail.isEmpty ? nil : detail,
            dueDate: dueDate
        )
        item.priority = priority
        
        // If there's a category, add the item to it
        if let category = selectedCategory {
            if category.items == nil {
                category.items = []
            }
            category.items?.append(item)
        }
        
        save(item)
    }
    
    /// Creates a new compliance category using the value of `newCategoryName`, saves it, and sets it as the currently selected category.
    ///
    /// - Side Effects:
    ///   - Persists the new `ComplianceCategory` by calling `save(_:)`.
    ///   - Updates the `selectedCategory` to the newly created category.
    ///   - Resets `newCategoryName` to an empty string.
    ///   - Sets `isCreatingNewCategory` to `false` to indicate the creation process is complete.
    func createCategory(existingCategories: [ComplianceCategory]) {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if category already exists (case insensitive)
        if let existingCategory = existingCategories.first(where: {
            $0.title.lowercased() == trimmedName.lowercased()
        }) {
            // Use existing category
            selectedCategory = existingCategory
        } else {
            // Create new category
            let category = ComplianceCategory(title: trimmedName)
            save(category)
            selectedCategory = category
        }
        
        newCategoryName = ""
        isCreatingNewCategory = false
    }
    
    /// Calculates and returns the count of compliance items in each status category.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to be analyzed.
    /// - Returns: A tuple containing the counts for each status:
    ///   - `pending`: The number of items with a status of `.pending`.
    ///   - `inProgress`: The number of items with a status of `.inProgress`.
    ///   - `completed`: The number of items with a status of `.completed`.
    ///   - `overdue`: The number of items that are overdue, determined by `isOverdue`.
    func stats(items: [ComplianceItem]) -> (pending: Int, inProgress: Int, completed: Int, overdue: Int) {
        let pending = items.filter { $0.status == .pending }.count
        let inProgress = items.filter { $0.status == .inProgress }.count
        let completed = items.filter { $0.status == .completed }.count
        let overdue = items.filter { $0.isOverdue }.count
        return (pending, inProgress, completed, overdue)
    }
    
    /// Filters an array of `ComplianceItem` objects based on user search text and optional status and priority filters.
    ///
    /// - Parameter items: An array of `ComplianceItem` instances to be filtered.
    /// - Returns: A filtered array of `ComplianceItem` objects that match the following criteria:
    ///   - If `searchText` is not empty, only items whose title or detail contains the search text (case-insensitive) are included.
    ///   - If `filterStatus` is set, only items matching the selected status are included.
    ///   - If `filterPriority` is set, only items matching the selected priority are included.
    ///
    /// The function applies the filters in the following order: search text, status, then priority.
    func filtered(items: [ComplianceItem]) -> [ComplianceItem] {
        var result = items
        
        if !searchText.isEmpty {
            result = result.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                (item.detail ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        
        if let priority = filterPriority {
            result = result.filter { $0.priority == priority }
        }
        
        return result
    }
    /// Groups compliance items into time-based categories for display or analysis.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to be grouped.
    /// - Returns: An array of tuples, where each tuple contains:
    ///   - A `String` representing the group label ("Overdue", "This Week", "This Month", or "Later").
    ///   - An array of `ComplianceItem` objects belonging to that group, sorted by `dueDate` in ascending order.
    ///
    /// The grouping logic works as follows:
    /// - Items for which `isOverdue` is `true` are grouped under "Overdue".
    /// - Items with `daysToDue` less than or equal to 7 are grouped under "This Week".
    /// - Items with `daysToDue` less than or equal to 30 (but greater than 7) are grouped under "This Month".
    /// - Remaining items are grouped under "Later".
    ///
    /// Only non-empty groups are included in the returned array, and the groups are ordered as:
    /// "Overdue", "This Week", "This Month", "Later".
    /// This method filters items using `filtered(items:)` before grouping.
    func groupedItems(items: [ComplianceItem]) -> [(String, [ComplianceItem])] {
        let grouped = Dictionary(grouping: filtered(items: items)) { item in
            if item.isOverdue {
                return "Overdue"
            } else if item.daysToDue <= 7 {
                return "This Week"
            } else if item.daysToDue <= 30 {
                return "This Month"
            } else {
                return "Later"
            }
        }
        
        let order = ["Overdue", "This Week", "This Month", "Later"]
        return order.compactMap { key in
            guard let items = grouped[key] else { return nil }
            return (key, items.sorted { $0.dueDate < $1.dueDate })
        }
    }
}
