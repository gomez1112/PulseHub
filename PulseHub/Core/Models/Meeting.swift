//
//  Meeting.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData
import SwiftUI

/// A model representing a scheduled meeting within the PulseHub system.
/// 
/// The `Meeting` class encapsulates all relevant data for a meeting, including its title,
/// date, attendees, type, and notes. It also manages relationships to related entities,
/// such as decisions made during the meeting, compliance items discussed, and classroom
/// walkthrough observations. Meeting status and type provide further categorization and
/// utility properties for display and organization.
///
/// - Properties:
///   - title: The title of the meeting.
///   - date: The calendar date of the meeting.
///   - attendees: An array of attendee names as strings.
///   - startTime: The starting time of the meeting.
///   - endTime: The ending time of the meeting.
///   - status: The current status of the meeting, represented by `MeetingStatus`.
///   - type: The category of the meeting, represented by `MeetingType`.
///   - notes: Optional notes or summary for the meeting.
///   - duration: Computed property representing the meeting's duration as a measurement in minutes.
///   - decisions: An array of `Decision` objects related to this meeting.
///   - complianceItems: An array of `ComplianceItem` objects discussed or tracked in this meeting.
///   - observations: An array of `ClassroomWalkthrough` objects associated with this meeting (e.g., observational notes).
///
/// - Initialization:
///   Provides an initializer to set key details upon creation, such as title, date, attendees,
///   meeting type, notes, and related objects.
///
/// - Relationships:
///   Utilizes inverse relationships with other models (e.g., `Decision.meeting`) for rich data modeling.
///
/// - Sample Data:
///   Includes static sample meetings for previewing and testing purposes.
@Model
final class Meeting: Identifiable {
    var id = UUID()
    var title = ""
    var date = Date()
    var attendees: [String] = []
    var startTime = Date()
    var endTime = Date()
    var status = MeetingStatus.cancelled
    var type: MeetingType = MeetingType.admin
    var notes: String? = nil
    
    var duration: Measurement<UnitDuration> {
        Measurement(value: endTime.timeIntervalSince(startTime), unit: .hours) 
    }
    var formatterDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        formatter.zeroFormattingBehavior = .dropAll
        
        let interval = endTime.timeIntervalSince(startTime)
        return formatter.string(from: interval) ?? "0 minutes"
    }
    
    @Relationship(inverse: \Decision.meeting)
    var decisions: [Decision]?
    
    @Relationship(inverse: \ComplianceItem.meeting)
    var complianceItems: [ComplianceItem]?
    
    @Relationship(inverse: \ClassroomWalkthrough.meeting)
    var observations: [ClassroomWalkthrough]?
    
    init(
        title: String,
        date: Date = .init(),
        attendees: [String] = [],
        type: MeetingType,
        notes: String? = nil,
        decisions: [Decision] = [],
        complianceItems: [ComplianceItem] = [],
        observations: [ClassroomWalkthrough] = []
    ) {
        self.title = title
        self.date = date
        self.attendees = attendees
        self.type = type
        self.notes = notes
        self.decisions = decisions
        self.complianceItems = complianceItems
        self.observations = observations
    }
}
enum MeetingStatus: String, Identifiable, CaseIterable, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case rescheduled = "Rescheduled"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
            case .scheduled: return "calendar.badge.clock"
            case .inProgress: return "dot.radiowaves.left.and.right"
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle.fill"
            case .rescheduled: return "calendar.badge.exclamationmark"
        }
    }
    var color: Color {
        switch self {
            case .scheduled: return .blue
            case .inProgress: return .orange
            case .completed: return .green
            case .cancelled: return .red
            case .rescheduled: return .yellow
        }
    }

    var statusToComplianceStatus: ComplianceStatus {
        switch self {
            case .scheduled: return .pending
            case .inProgress: return .inProgress
            case .completed: return .completed
            case .cancelled: return .cancelled
            case .rescheduled: return .pending
        }
    }
}
enum MeetingType: String, Codable, CaseIterable, Identifiable {
    case parent            = "Parent Meeting"
    case student           = "Student Meeting"
    case staff             = "Staff Meeting"
    case admin             = "Admin Meeting"
    case preObservation    = "Pre-Observation Meeting"
    case postObservation   = "Post-Observation Meeting"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
            case .parent: "person.2"
            case .student: "graduationcap"
            case .staff: "person.3"
            case .admin: "building.2"
            case .preObservation: "eye.trianglebadge.exclamationmark"
            case .postObservation: "eye.circle"
        }
    }
}

// MARK: - Sample Data
@MainActor
extension Meeting {
    static let samples: [Meeting] = [
        Meeting(
            title: "Admin Team Meeting",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            attendees: ["Alice Johnson", "Bob Smith"],
            type: .admin,
            notes: "Discuss upcoming school year goals.",
            decisions: [Decision(title: "Fail everyone"), Decision(title: "Pass everyone")],
            complianceItems: [],
            observations: []
        ),
        Meeting(
            title: "Staff Meeting",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            attendees: ["Carol Lee", "David Brown", "Eva Green"],
            type: .staff,
            decisions: [],
            complianceItems: [],
            observations: []
        )
    ]
}
