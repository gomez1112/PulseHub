//
//  OpenMeetingIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct OpenMeetingIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Meeting"
    static let description = IntentDescription("Open a specific meeting in PulseHub.")

    @Parameter(title: "Meeting")
    var meeting: MeetingEntity

    init() {}

    // Convenience initializer to allow calling with a Meeting model directly from the widget code.
    init(meeting: Meeting) {
        self.meeting = MeetingEntity(meeting: meeting)
    }

    func perform() async throws -> some IntentResult {
        // Deep link into the app to the specific meeting.
        // Ensure your app handles this URL scheme: pulsehub://meeting/<uuid>
        let url = URL(string: "pulsehub://meeting/\(meeting.id.uuidString)")!
        return .result(value: url)
    }
}
