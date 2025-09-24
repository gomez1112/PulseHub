//
//  DataModel.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import Observation
import SwiftData

/// `DataModel` serves as the primary observable data controller for the application,
/// managing the main SwiftData context and exposing reactive properties for various features and UI states.
/// 
/// - Manages Core Data/SwiftData operations (`save`, `delete`) for objects conforming to `PersistentModel`.
/// - Tracks UI state and user selections for features including Compliance, Dashboard, Decision, Meeting, and Search.
/// - Exposes properties for filtering, sorting, and view preferences across the app.
/// - Designed for dependency injection with a `ModelContainer`, providing a consistent `ModelContext` throughout.
///
/// ### Properties by Feature:
/// - **Compliance:** Handles category selection, stats visibility, category creation, searching, and filtering by status/priority.
/// - **Dashboard:** Maintains the selected time range for dashboard analytics.
/// - **Decision:** Filters by effectiveness/impact and toggles analytics display.
/// - **Meeting:** Filters by meeting type and view mode (list/grid).
/// - **Search:** Manages sort order and filter UI state.
///
/// ### Usage:
/// Inject and observe an instance of `DataModel` to coordinate data access, persistence, and UI state.
///
/// ### Example:
/// ```swift
/// @Environment(DataModel.self) var dataModel
/// ```
@Observable
@MainActor
final class DataModel {
    
    let context: ModelContext
    
    init(container: ModelContainer) {
        self.context = container.mainContext
    }
    
    /// Saves the given `PersistentModel` object to the main SwiftData context.
    /// 
    /// - Parameter model: The object conforming to `PersistentModel` to be persisted.
    /// 
    /// This method inserts the specified model into the application's primary data context,
    /// making it available for queries and persistence. 
    ///
    /// - Note: The insertion does not immediately write to disk; saving changes may require committing the context,
    /// depending on the underlying SwiftData implementation.
    ///
    /// ### Example
    /// ```swift
    /// let newItem = MyModel(...)
    /// dataModel.save(newItem)
    /// ```
    func save<T: PersistentModel>(_ model: T) {
        context.insert(model)
    }
    
    /// Deletes the given `PersistentModel` object from the main SwiftData context.
    ///
    /// - Parameter model: The object conforming to `PersistentModel` to be removed.
    ///
    /// This method removes the specified model from the application's primary data context,
    /// marking it for deletion. 
    ///
    /// - Note: The deletion does not immediately write to disk; saving changes may require committing the context,
    /// depending on the underlying SwiftData implementation.
    ///
    /// ### Example
    /// ```swift
    /// let itemToRemove = MyModel(...)
    /// dataModel.delete(itemToRemove)
    /// ```
    func delete<T: PersistentModel>(_ model: T) {
        context.delete(model)
    }
    
    func fetchItems<M: PersistentModel>( of _: M.Type, predicate: Predicate<M> = #Predicate { _ in true }, sortBy: [SortDescriptor<M>] = [], limit: Int? = nil) throws -> [M] {
        var descriptor = FetchDescriptor<M>(predicate: predicate, sortBy: sortBy)
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }
    
    /// Checks if the given string is non-empty after trimming whitespace and newlines.
    ///
    /// - Parameter trimming: The string to be trimmed and validated.
    /// - Returns: `true` if the trimmed string is not empty; otherwise, `false`.
    func isValid(trimming: String) -> Bool {
        !trimming.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    //MARK: Compliance
    var overdueItemsCount = 0
    var isShowingStats = false
    var isCreatingNewCategory = false
    var newCategoryName = ""
    var searchText = ""
    var filterStatus: ComplianceStatus? = nil
    var filterPriority: Priority? = nil
    
    //MARK: Dashboard
    var selectedTimeRange: TimeRange = .week
    
    //MARK: Decision
    var filterEffectiveness: Bool? = nil
    var filterImpact: ImpactLevel? = nil
    var showAnalytics = false
    
    //MARK: Meeting
    var filterType: MeetingType? = nil
    var viewMode = ViewMode.list
    var todayMeetingsCount = 0
    //MARK: Search
    var sortOrder: SortOrder = .relevance
    var isShowingFilters = false
    
    //MARK: Observation
    var isShowingAddComponent = false
    var teacherName = ""
    var subject = ""
}

