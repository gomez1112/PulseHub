//
//  ComplianceCategory.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData

/// A model representing a compliance category in the PulseHub application.
///
/// `ComplianceCategory` serves as a logical grouping for related compliance items (e.g., Safety, HR Policies).
/// Each category contains a collection of `ComplianceItem` objects and provides a title to describe the group.
///
/// - Properties:
///   - title: The name or label of the compliance category.
///   - items: The list of compliance items associated with this category. This is a to-many relationship,
///            with a cascade delete rule to ensure items are removed when the category is deleted.
///
/// - Relationships:
///   - Each `ComplianceItem` has a reference back to its parent `ComplianceCategory`.
///
/// - Initialization:
///   - You can initialize with a custom title and set of items. By default, the title is "Category"
///     and the item list is empty.
///
/// - Sample Data:
///   - The `samples` static property provides example categories with sample items for use in previews and tests.
@Model
final class ComplianceCategory {
    var title = ""
    
    @Relationship(deleteRule: .cascade, inverse: \ComplianceItem.category)
    var items: [ComplianceItem]? = []
    
    init(title: String = "Category", items: [ComplianceItem] = []) {
        self.title = title
        self.items = items
    }
}

// MARK: - Sample Data

@MainActor
extension ComplianceCategory {
    static let samples: [ComplianceCategory] = {
        
        let safetyCategory = ComplianceCategory(title: "Safety", items: [ComplianceItem.samples[0], ComplianceItem.samples[2]])
        let hrCategory = ComplianceCategory(title: "HR Policies", items: [ComplianceItem.samples[1]])
        // Assign category references to items
        safetyCategory.items?.forEach { $0.category = safetyCategory }
        hrCategory.items?.forEach { $0.category = hrCategory }
        return [safetyCategory, hrCategory]
    }()
}
