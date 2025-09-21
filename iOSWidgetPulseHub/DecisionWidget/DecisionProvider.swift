//
//  DecisionProvider.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import SwiftData
import WidgetKit


@MainActor
struct DecisionProvider: AppIntentTimelineProvider {
    typealias Intent = DecisionWidgetIntent
    typealias Entry = DecisionEntry
    
    func placeholder(in context: Context) -> DecisionEntry {
        DecisionEntry(date: Date(), stats: sampleStats)
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> DecisionEntry {
        DecisionEntry(date: Date(), stats: await fetchDecisionStats())
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<DecisionEntry> {
        let stats = await fetchDecisionStats()
        let entry = DecisionEntry(date: Date(), stats: stats)
        
        return Timeline(entries: [entry], policy: .never)
    }
    
    private func fetchDecisionStats() async -> DecisionStats {
        do {
            let container = ModelContainerFactory.createSharedContainer
            let context = container.mainContext
            let descriptor = FetchDescriptor<Decision>()
            let decisions = try context.fetch(descriptor)
            
            let effective = decisions.filter { $0.wasEffective == true }.count
            let ineffective = decisions.filter { $0.wasEffective == false }.count
            let pending = decisions.filter { $0.wasEffective == nil }.count
            
            let recentDecisions = decisions
                .filter { $0.wasEffective == nil }
                .sorted { $0.dateMade > $1.dateMade }
                .prefix(3)
                .map { DecisionEntity(decision: $0) }
            
            return DecisionStats(
                effective: effective,
                ineffective: ineffective,
                pending: pending,
                recentDecisions: Array(recentDecisions)
            )
        } catch {
            return sampleStats
        }
    }
    
    var sampleStats: DecisionStats {
        // Build a temporary Decision model and wrap it in a DecisionEntity
        let sampleDecision = Decision(
            title: "Implement New Policy",
            dateMade: Date(),
            wasEffective: nil
        )
        sampleDecision.impact = .high
        sampleDecision.rationale = "Improve efficiency"
        
        return DecisionStats(
            effective: 12,
            ineffective: 3,
            pending: 5,
            recentDecisions: [
                DecisionEntity(decision: sampleDecision)
            ]
        )
    }
}
