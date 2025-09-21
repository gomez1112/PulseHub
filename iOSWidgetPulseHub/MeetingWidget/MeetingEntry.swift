//
//  MeetingEntry.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents
import WidgetKit


struct MeetingEntry: TimelineEntry {
    let date: Date
    let meetings: [Meeting]
    let showMeetingCount: Bool
    
    var nextMeeting: Meeting? {
        meetings.first { $0.date > Date() }
    }
}

