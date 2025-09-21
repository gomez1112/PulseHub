//
//  ComplianceItemQuery.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ComplianceItemQuery: EntityQuery {
    @Dependency private var model: DataModel
    
    func entities(for identifiers: [UUID]) async throws -> [ComplianceItemEntity] {
        try await model.complianceItemEntities(matching: #Predicate {
            identifiers.contains($0.id)
        })
    }
    
    
    func suggestedEntities() async throws -> [ComplianceItemEntity] {
        // Return suggested items
        try await model.suggest5ComplianceItemEntities()
    }
}
