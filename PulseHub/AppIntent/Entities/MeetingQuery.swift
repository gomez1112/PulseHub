//
//  MeetingQuery.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct MeetingQuery: EntityQuery {
    @Dependency private var model: DataModel
    func entities(for identifiers: [UUID]) async throws -> [MeetingEntity] {
        try await model.meetingEntities(matching: #Predicate {
            identifiers.contains($0.id)
        })
    }
    
    
    func suggestedEntities() async throws -> [MeetingEntity] {
        try await model.meetingEntities()
    }
}
