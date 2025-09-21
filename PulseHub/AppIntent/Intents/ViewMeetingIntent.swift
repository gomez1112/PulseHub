//
//  ViewMeetingIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ViewMeetingIntent: AppIntent {
    static let title: LocalizedStringResource = "View Meeting"
    static let description = IntentDescription("Opens meeting details in PulseHub")
    
    @Parameter(title: "Meeting")
    var meeting: MeetingEntity
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
