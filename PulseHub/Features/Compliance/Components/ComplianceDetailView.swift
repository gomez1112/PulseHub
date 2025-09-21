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
    
    @Bindable var item: ComplianceItem
 
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Status Section
                statusSection
                
                // Details Section
                if let detail = item.detail {
                    detailSection(detail: detail)
                }
                
                // Notes Section
                notesSection
                
                // Related Meeting
                if let meeting = item.meeting {
                    relatedMeetingSection(meeting: meeting)
                }
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .background(Color.chipBackground)
        .navigationTitle("Compliance Item")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Delete Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                context.delete(item)
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
                    Text(item.category?.title ?? "No Category")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(item.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: item.priority.icon)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(item.priority.color)
                    .padding()
                    .background {
                        Circle()
                            .fill(item.priority.color.opacity(0.15))
                    }
            }
            
            HStack(spacing: 16) {
                Label {
                    Text(item.createdDate.formatted(date: .abbreviated, time: .omitted))
                } icon: {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                
                Label {
                    Text(LocalizedStringResource(stringLiteral: item.dueText))
                        .foregroundStyle(item.isOverdue ? .red : .primary)
                } icon: {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .foregroundStyle(item.isOverdue ? .red : .secondary)
                }
                .font(.caption.weight(item.isOverdue ? .semibold : .regular))
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
                StatusPicker(selection: $item.status)
                
                Spacer()
                
                Toggle(isOn: $item.isResolved) {
                    Label("Resolved", systemImage: item.isResolved ? "checkmark.circle.fill" : "circle")
                        .font(.callout.weight(.medium))
                }
                .toggleStyle(.button)
                .buttonStyle(.bordered)
                .tint(item.isResolved ? .green : .gray)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10)
        }
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
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
            
            TextEditor(text: $item.notes)
                .font(.callout)
                .foregroundStyle(.primary)
                .frame(minHeight: 100)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.quaternary)
                }
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
                item.status = .completed
                item.isResolved = true
                item.completedDate = Date()
            } label: {
                Label("Mark Complete", systemImage: "checkmark.circle.fill")
                    //.frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(item.isResolved)
            Spacer()
            Button {
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview(traits: .previewData) {
    NavigationStack {
        ComplianceDetailView(item: ComplianceItem.samples[0])
    }
}
