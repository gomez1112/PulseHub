//
//  DecisionEntity.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct DecisionEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Decision")
    static let defaultQuery = DecisionQuery()
    
    let id: UUID
    let title: String
    let dateMade: Date
    let impact: String
    let wasEffective: Bool?
    let rationale: String
    
    init(decision: Decision) {
        self.id = decision.id
        self.title = decision.title
        self.dateMade = decision.dateMade
        self.impact = decision.impact.rawValue
        self.wasEffective = decision.wasEffective
        self.rationale = decision.rationale
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: LocalizedStringResource(stringLiteral: impact),
            image: .init(systemName: "lightbulb")
        )
    }
}
