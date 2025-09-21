//
//  ComplianceItem.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData
import SwiftUI

/// A model representing a compliance task or requirement, typically associated with organizational or regulatory obligations.
///
/// `ComplianceItem` encapsulates the properties and behaviors needed to track compliance-related tasks, including their status,
/// priority, relevant dates, and links to associated meetings or categories.
///
/// - Properties:
///   - title: A brief description of the compliance item.
///   - detail: An optional detailed explanation or notes about the item.
///   - createdDate: The date and time the compliance item was created.
///   - notes: Additional notes or comments related to the item.
///   - dueDate: The deadline by which the compliance item should be completed.
///   - status: The current status (`ComplianceStatus`) of the item.
///   - isResolved: A boolean indicating whether the item has been resolved.
///   - completedDate: The date the item was marked as completed, if applicable.
///   - priority: The priority level for the compliance item (`Priority`).
///   - category: The category (`ComplianceCategory`) grouping this compliance item.
///   - meeting: An optional link to a meeting (`Meeting`) related to the compliance request.
///
/// - Computed Properties:
///   - isOverdue: Returns `true` if the item is not completed and the due date has passed.
///   - daysToDue: The number of days from the current date until the due date (negative if overdue).
///   - dueText: A user-friendly text representation of the due status (e.g., “Due today”, “Due in 3 days”).
///
/// - Initializer:
///   Initializes a `ComplianceItem` with a title, category, optional details, due date, and optional meeting.
///
/// - Sample Data:
///   Includes example categories, meetings, and sample compliance items for preview or testing.
///
@Model
final class ComplianceItem: Identifiable {
    var id = UUID()
    var title = ""
    var detail: String?
    var createdDate = Date()
    var notes: String = ""
    var dueDate = Date()
    var status = ComplianceStatus.cancelled
    var isResolved = false
    var completedDate: Date?
    var priority = Priority.critical
    var category: ComplianceCategory?
    var meeting: Meeting?
    
    @Relationship(deleteRule: .cascade, inverse: \ItemTask.item) private var tasks: [ItemTask]? = []
    
    var isOverdue: Bool { status != .completed && dueDate < Date() }
    
    var daysToDue: Int { Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0 }
    
    var remainingTaskCount: Int {
        tasks?.filter { !$0.isCompleted }.count ?? 0
    }
    
    var isCompleted: Bool {
        tasks?.allSatisfy { $0.isCompleted } ?? false
    }
    
    
    
    var dueText: String {
        if isOverdue {
            return "Overdue by ^[\(abs(daysToDue)) days](inflect: true)"
        } else if daysToDue == 0 {
            return "Due today"
        } else {
            return "Due in ^[\(daysToDue) days](inflect: true)"
        }
    }
    
    init(
        title: String,
        category: ComplianceCategory?,
        detail: String? = nil,
        dueDate: Date,
        meeting: Meeting? = nil
    ) {
        self.title = title
        self.category = category
        self.detail = detail
        self.dueDate = dueDate
        self.meeting = meeting
    }
}
/// Represents the status of a compliance item, indicating its current stage in the workflow.
///
/// - Cases:
///   - pending: The compliance item is awaiting action and has not yet started.
///   - inProgress: Work on the compliance item is currently underway.
///   - completed: The compliance item has been finished and all required actions are done.
///   - overdue: The compliance item was not completed by its due date.
///   - cancelled: The compliance item was cancelled and will not be completed.
///
/// Provides convenient properties for display, such as associated colors and system icon names.
enum ComplianceStatus: String, Identifiable, CaseIterable, Codable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    
    var id: Self { self }
    
    var color: Color {
        switch self {
            case .pending: return .gray
            case .inProgress: return .blue
            case .completed: return .green
            case .overdue: return .red
            case .cancelled: return .orange
        }
    }
    
    var icon: String {
        switch self {
            case .pending: return "clock"
            case .inProgress: return "arrow.right.circle"
            case .completed: return "checkmark.circle"
            case .overdue: return "exclamationmark.circle"
            case .cancelled: return "xmark.circle"
        }
    }
}

// MARK: - Sample Data
@MainActor
extension ComplianceItem {
    static let sampleCategory1 = ComplianceCategory(title: "Safety")
    static let sampleCategory2 = ComplianceCategory(title: "Testing")
    static let sampleMeeting = Meeting(title: "Board Meeting", date: Date(), type: .admin)
    
    static let samples: [ComplianceItem] = [
        ComplianceItem(
            title: "Fire Drill Documentation",
            category: sampleCategory1,
            detail: "Ensure all fire drill logs are up to date.",
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        ),
        ComplianceItem(
            title: "Regents testing Proctor",
            category: sampleCategory2,
            detail: "Revise the handbook to include new regents.",
            dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        ),
        ComplianceItem(
            title: "Annual Safety Training",
            category: sampleCategory1,
            detail: "All staff must complete annual safety training.",
            dueDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        )
    ]
}
