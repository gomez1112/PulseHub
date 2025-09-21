//
//  DecisionQuery.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct DecisionQuery: EntityQuery {
    @Dependency private var model: DataModel
    func entities(for identifiers: [UUID]) async throws -> [DecisionEntity] {
        try await model.decisionEntities(matching: #Predicate {
            identifiers.contains($0.id)
        })
    }
    
    
    func suggestedEntities() async throws -> [DecisionEntity] {
        try await model.decisionEntities()
    }
}
