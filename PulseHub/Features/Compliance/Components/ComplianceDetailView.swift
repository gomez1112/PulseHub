//
//  ComplianceDetailView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftData
import SwiftUI

struct ComplianceDetailView: View {
    @Environment(NavigationContext.self) private var navigation
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var task: ProjectTask
 
    @State private var showDeleteAlert = false
    @State private var newTaskTitle = ""
    @FocusState private var isTaskFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                statusSection
                subtasksSection
                if let detail = task.detail, !detail.isEmpty {
                    detailSection(detail: detail)
                }
                
                // Related Meeting
                if let meeting = task.meeting {
                    relatedMeetingSection(meeting: meeting)
                }
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .background(Color.chipBackground)
        .navigationTitle(task.taskType == .compliance ? "Compliance Item" : "Task Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Delete Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                context.delete(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this compliance item? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(task.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: task.priority.icon)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(task.priority.color)
                    .padding()
                    .background {
                        Circle()
                            .fill(task.priority.color.opacity(0.15))
                    }
            }
            
            HStack(spacing: 16) {
                Label {
                    Text(task.createdDate.formatted(date: .abbreviated, time: .omitted))
                } icon: {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                
                Label {
                    Text(LocalizedStringResource(stringLiteral: task.dueText))
                        .foregroundStyle(task.isOverdue ? .red : .primary)
                } icon: {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .foregroundStyle(task.isOverdue ? .red : .secondary)
                }
                .font(.caption.weight(task.isOverdue ? .semibold : .regular))
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Status", systemImage: "info.circle")
                .font(.headline)
            
            HStack {
                StatusPicker(selection: $task.status)
                
                Spacer()
            }
        }
        .padding()
        .cardStyle()
    }
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Checklist (\(task.remainingTaskCount) remaining)", systemImage: "checklist")
                .font(.headline)
            
            if let subtasks = task.subtasks, !subtasks.isEmpty {
                ForEach(subtasks) { subtask in
                    HStack(spacing: 12) {
                        Button {
                            withAnimation {
                                if subtask.status == .completed {
                                    subtask.status = .pending
                                } else {
                                    subtask.status = .completed
                                }
                                updateParentStatus()
                            }
                        } label: {
                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(subtask.isCompleted ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                        
                        TextField("Subtask Title", text: Binding(get: { subtask.title }, set: { subtask.title = $0 }))
                            .strikethrough(subtask.isCompleted, color: .primary)
                            .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                        
                        Spacer()
                    }
                    .swipeActions {
                        Button(role: .destructive) { deleteSubtask(subtask) } label: { Label("Delete", systemImage: "trash") }
                    }
                    Divider()
                }
            }
            
            HStack {
                TextField("Add new sub-task...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .focused($isTaskFieldFocused)
                    .onSubmit(addNewSubtask)
                Button(action: addNewSubtask) {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
                .disabled(newTaskTitle.isEmpty)
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding()
        .cardStyle()
    }
    private func detailSection(detail: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Details", systemImage: "doc.text")
                .font(.headline)
            
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
    
    private func relatedMeetingSection(meeting: Meeting) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Related Meeting", systemImage: "calendar")
                .font(.headline)
            Button {
                navigation.navigate(to: .meeting(meeting))
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meeting.title)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        Text(meeting.date.formatted())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.quaternary)
                }
            }
            .buttonStyle(.plain)

        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                task.status = .completed
                task.completedDate = Date()
            } label: {
                Label("Mark Complete", systemImage: "checkmark.circle.fill")
                    //.frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(task.isCompleted)
            Spacer()
            Button {
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    // MARK: - Helper Functions
    private func addNewSubtask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let subtask = ProjectTask(title: newTaskTitle.trimmingCharacters(in: .whitespaces))
        subtask.parentTask = task
        
        if task.subtasks == nil {
            task.subtasks = []
        }
        task.subtasks?.append(subtask)
        
        newTaskTitle = ""
        isTaskFieldFocused = false
        updateParentStatus()
    }
    private func deleteSubtask(_ subtask: ProjectTask) {
        if let index = task.subtasks?.firstIndex(where: { $0.id == subtask.id }) {
            task.subtasks?.remove(at: index)
            // The subtask is deleted from the context because of the .cascade delete rule
            updateParentStatus()
        }
    }
    private func updateParentStatus() {
        if task.isCompleted {
            task.status = .completed
            if task.completedDate == nil {
                task.completedDate = Date()
            }
        } else {
            let hasCompletedSubtasks = task.subtasks?.contains { $0.isCompleted } ?? false
            task.status = hasCompletedSubtasks ? .inProgress : .pending
            task.completedDate = nil
        }
    }
}

#Preview(traits: .previewData) {
    NavigationStack {
        ComplianceDetailView(task: ProjectTask(title: "New Task"))
    }
}
