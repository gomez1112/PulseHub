//
//  ComplianceItemEntity.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ComplianceItemEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Compliance Item")
    static let defaultQuery = ComplianceItemQuery()
    
    let id: UUID
    let title: String
    let dueDate: Date
    let priority: String
    let isOverdue: Bool
    let categoryTitle: String?
    let status: String
    
    init(complianceItem: ComplianceItem) {
        self.id = complianceItem.id
        self.title = complianceItem.title
        self.dueDate = complianceItem.dueDate
        self.priority = complianceItem.priority.rawValue
        self.isOverdue = complianceItem.isOverdue
        self.categoryTitle = complianceItem.category?.title
        self.status = complianceItem.status.rawValue
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: categoryTitle.map { LocalizedStringResource(stringLiteral: $0) },
            image: .init(systemName: isOverdue ? "exclamationmark.triangle.fill" : "checkmark.shield")
        )
    }
}
