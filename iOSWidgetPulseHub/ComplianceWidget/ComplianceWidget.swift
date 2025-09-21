//
//  ComplianceWidget.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import SwiftUI
import WidgetKit


struct ComplianceWidget: Widget {
    let kind: String = "ComplianceWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ComplianceWidgetIntent.self,
            provider: ComplianceProvider()
        ) { entry in
    
                ComplianceWidgetView(entry: entry)
            
        }
        .configurationDisplayName("Compliance Tracker")
        .description("Monitor overdue and upcoming compliance items")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
