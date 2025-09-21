//
//  ReviewDecisionIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ReviewDecisionIntent: AppIntent {
    static let title: LocalizedStringResource = "Review Decision"
    static let description = IntentDescription("Review a decision's effectiveness")
    static let openAppWhenRun: Bool = false
    
    @Dependency private var model: DataModel
    @Parameter(title: "Decision")
    var decision: DecisionEntity
    
    @Parameter(title: "Was Effective")
    var wasEffective: Bool
    
    init() {}
    
    init(decision: DecisionEntity, wasEffective: Bool) {
        self.decision = decision
        self.wasEffective = wasEffective
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let decisions = try model.fetchItems(of: Decision.self)
        
        if let matchingDecision = decisions.first(where: { $0.title == decision.title }) {
            matchingDecision.wasEffective = wasEffective
            model.save(matchingDecision)
            
            let status = wasEffective ? "effective" : "ineffective"
            return .result(dialog: "Marked \(decision.title) as \(status)")
        }
        
        return .result(dialog: "Could not find decision")
    }
}
