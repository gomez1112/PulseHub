//
//  Decision.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData
import SwiftUI

/// A record representing a decision made within an organization or meeting context.
/// 
/// The `Decision` model captures key attributes related to an organizational or team decision, 
/// including the decision’s title, details, date, impact, rationale, effectiveness, and reflection. 
/// It optionally links to a related `Meeting`, enabling historical tracking and contextual reference.
///
/// - Properties:
///   - title: The main title or summary of the decision.
///   - detail: Additional descriptive information about the decision.
///   - dateMade: The date when the decision was made.
///   - nextSteps: Any follow-up actions or steps resulting from the decision.
///   - impact: The assessed level of impact associated with the decision (see `ImpactLevel`).
///   - rationale: The reasoning or justification behind the decision.
///   - wasEffective: An optional boolean indicating whether the decision proved effective.
///   - reflection: Notes or reflections on the outcome or process of the decision.
///   - meeting: An optional reference to the meeting where the decision was made.
///
/// - Note: 
///   `Decision` provides sample data for preview and development purposes via the 
///   static `samples` property.
@Model
final class Decision: Identifiable {
    var id = UUID()
    var title = ""
    var detail: String?
    var dateMade = Date()
    var nextSteps: String?
    var impact = ImpactLevel.critical
    var rationale = ""
    var wasEffective: Bool?
    var reflection: String?

    var meeting: Meeting?

    init(
        title: String,
        detail: String? = nil,
        dateMade: Date = .init(),
        nextSteps: String? = nil,
        wasEffective: Bool? = nil,
        reflection: String? = nil,
        meeting: Meeting? = nil
    ) {
        self.title = title
        self.detail = detail
        self.dateMade = dateMade
        self.nextSteps = nextSteps
        self.wasEffective = wasEffective
        self.reflection = reflection
        self.meeting = meeting
    }
}

enum ImpactLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: Color {
        switch self {
            case .low: return .blue
            case .medium: return .orange
            case .high: return .red
            case .critical: return .purple
        }
    }
    var icon: String {
        switch self {
            case .low: return "arrow.down.circle"
            case .medium: return "minus.circle"
            case .high: return "arrow.up.circle"
            case .critical: return "exclamationmark.triangle"
        }
    }
    var description: String {
        switch self {
            case .low: return "Minor operational changes with limited scope"
            case .medium: return "Moderate changes affecting multiple areas"
            case .high: return "Significant changes with broad implications"
            case .critical: return "Major strategic decisions with organization-wide impact"
        }
    }
}

// MARK: - Sample Data
@MainActor
extension Decision {
    static let sampleMeeting = Meeting(title: "Leadership Team Meeting", date: Date(), type: .admin)
    
    static let samples: [Decision] = [
        Decision(
            title: "Implement New Onboarding Process",
            detail: "Adopt the revised onboarding checklist for all new hires.",
            dateMade: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            nextSteps: "Schedule training for managers.",
            wasEffective: true,
            reflection: "The process improved efficiency.",
            meeting: sampleMeeting
        ),
        Decision(
            title: "Switch to Digital Attendance",
            detail: "Move all staff attendance to the digital system.",
            dateMade: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
            nextSteps: "Notify staff and provide login details.",
            wasEffective: false,
            reflection: "Need more training for some staff.",
            meeting: sampleMeeting
        )
    ]
}
