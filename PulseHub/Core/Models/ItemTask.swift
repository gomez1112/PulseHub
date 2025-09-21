//
//  ItemTask.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/13/25.
//

import Foundation
import SwiftData

/// A model representing a task associated with a compliance item.
///
/// `ItemTask` is used to track tasks related to a specific `ComplianceItem`.
/// Each instance has a title, a completion status, and an optional reference to its associated compliance item.
///
/// - Properties:
///   - title: The title or description of the task.
///   - isCompleted: A Boolean value indicating whether the task has been completed.
///   - item: The associated `ComplianceItem`, if any.
@Model
final class ItemTask {
    var title = ""
    var isCompleted = false
    
    var item: ComplianceItem?
    
    init(title: String = "", isCompleted: Bool = false, item: ComplianceItem? = nil) {
        self.title = title
        self.isCompleted = isCompleted
        self.item = item
    }
}
