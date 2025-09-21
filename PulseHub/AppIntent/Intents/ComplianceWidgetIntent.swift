//
//  ComplianceWidgetIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ComplianceWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Compliance Widget"
    static let description = IntentDescription("Configure which compliance items to display")
    
    @Parameter(title: "Show Overdue Only")
    var showOverdueOnly: Bool?
    
    @Parameter(title: "Priority Filter")
    var priorityFilter: PriorityFilter?
    
    init() {
        // Provide sensible defaults while keeping the parameter types optional
        self.showOverdueOnly = false
        self.priorityFilter = .all
    }
    
    init(showOverdueOnly: Bool?, priorityFilter: PriorityFilter?) {
        self.showOverdueOnly = showOverdueOnly
        self.priorityFilter = priorityFilter
    }
}

enum PriorityFilter: String, AppEnum {
    case all, critical, high, medium, low
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Priority Filter")
    
    static let caseDisplayRepresentations: [PriorityFilter: DisplayRepresentation] = [
        .all: "All Priorities",
        .critical: "Critical Only",
        .high: "High Priority",
        .medium: "Medium Priority",
        .low: "Low Priority"
    ]
}
