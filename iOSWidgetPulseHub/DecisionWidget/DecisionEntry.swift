//
//  DecisionEntry.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import WidgetKit


struct DecisionEntry: TimelineEntry {
    let date: Date
    let stats: DecisionStats
}

struct DecisionStats {
    let effective: Int
    let ineffective: Int
    let pending: Int
    let recentDecisions: [DecisionEntity]
    
    var effectivenessRate: Double {
        let total = effective + ineffective
        return total > 0 ? Double(effective) / Double(total) : 0
    }
}
