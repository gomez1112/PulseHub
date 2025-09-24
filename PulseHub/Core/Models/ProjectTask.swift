//
//  ProjectTask.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/23/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ProjectTask: Identifiable {
    var id = UUID()
    var title: String = ""
    var detail: String?
    var createdDate: Date = Date()
    var dueDate: Date = Date()
    var completedDate: Date?
    var status = ComplianceStatus.pending
    var priority = Priority.medium
    var taskType = TaskType.general
    
    // For Compliance tasks
    var meeting: Meeting?
    
    // For Subtasks
    var parentTask: ProjectTask?
    
    var subtasks: [ProjectTask]? = []
    
    var isOverdue: Bool {
        // A task is overdue if it's not complete and its due date is in the past.
        status != .completed && dueDate < Date()
    }
    
    var daysToDue: Int {
        Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0
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
    
    var remainingTaskCount: Int {
        subtasks?.filter { !$0.isCompleted }.count ?? 0
    }
    
    var isCompleted: Bool {
        // A parent task is complete if all its subtasks are complete.
        // A task with no subtasks is complete if its status is .completed.
        guard let subtasks, !subtasks.isEmpty else {
            return status == .completed
        }
        return subtasks.allSatisfy { $0.isCompleted }
    }
    
    
    init(title: String, dueDate: Date = Date(), taskType: TaskType = .general, priority: Priority = .medium) {
        self.title = title
        self.dueDate = dueDate
        self.taskType = taskType
        self.priority = priority
    }
}

enum TaskType: String, Codable, CaseIterable {
    case general = "General"
    case compliance = "Compliance"
    case meetingFollowUp = "Meeting Follow-up"
    
    var icon: String {
        switch self {
            case .general: "list.bullet.clipboard"
            case .compliance: "checkmark.shield"
            case .meetingFollowUp: "calendar.badge.plus"
        }
    }
}
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
