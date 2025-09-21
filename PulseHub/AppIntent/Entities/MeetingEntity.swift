//
//  MeetingEntity.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct MeetingEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Meeting")
    static let defaultQuery = MeetingQuery()
    
    let id: UUID
    let title: String
    let date: Date
    let attendeesCount: Int
    let type: String
    let duration: String
    let startTime: Date
    
    init(meeting: Meeting) {
        self.id = meeting.id
        self.title = meeting.title
        self.date = meeting.date
        self.attendeesCount = meeting.attendees.count
        self.type = meeting.type.rawValue
        self.duration = meeting.duration.formatted()
        self.startTime = meeting.startTime
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(type) • \(attendeesCount) attendees",
            image: .init(systemName: "calendar")
        )
    }
}
