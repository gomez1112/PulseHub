//
//  DecisionWidgetIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct DecisionWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Decision Widget"
    static let description = IntentDescription("Configure decision metrics display")
    
    @Parameter(title: "Show Effectiveness Chart")
    var showChart: Bool?
    
    init() {
        self.showChart = true
    }
}
