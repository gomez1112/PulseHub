//
//  ScheduleWidgetIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ScheduleWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Schedule Widget"
    static let description = IntentDescription("Configure your schedule display")
    
    @Parameter(title: "Show Meeting Count")
    var showMeetingCount: Bool?
    
    init() {
        self.showMeetingCount = true
    }
}
