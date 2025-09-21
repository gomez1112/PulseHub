//
//  ScheduleWidget.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import SwiftUI
import WidgetKit


struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ScheduleWidgetIntent.self,
            provider: MeetingProvider()
        ) { entry in
            ScheduleWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Schedule")
        .description("View your meetings and appointments")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
