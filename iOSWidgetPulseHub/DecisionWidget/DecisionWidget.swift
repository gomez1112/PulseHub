//
//  DecisionWidget.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import SwiftUI
import WidgetKit


struct DecisionWidget: Widget {
    let kind: String = "DecisionWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: DecisionWidgetIntent.self,
            provider: DecisionProvider()
        ) { entry in
            DecisionWidgetView(entry: entry)
        }
        .configurationDisplayName("Decision Metrics")
        .description("Track decision effectiveness and pending reviews")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
