//
//  MeetingDetailView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct MeetingDetailView: View {
    let meeting: Meeting
    
    @Environment(DataModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationContext.self) private var navigation
    
    @State private var showDeleteAlert = false
    @State private var isStatusChanging = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with Animation
                headerSection
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                
                // Quick Stats
                quickStatsSection
                
                // Meeting Details
                meetingDetailsSection
        
                    if let notes = meeting.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(notes)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .cardStyle()
                        
                    }
                
                
                // Attendees
                if !meeting.attendees.isEmpty {
                    attendeesSection
                }
                
                // Related Decisions
                if let decisions = meeting.decisions, !decisions.isEmpty {
                    decisionsSection(decisions)
                }
                
                // Related Compliance Items
                if let items = meeting.complianceItems, !items.isEmpty {
                    complianceSection(items)
                }
                
                // Related Observations
                if let observations = meeting.observations, !observations.isEmpty {
                    observationsSection(observations)
                }
                
                // Timeline
                timelineSection
                
            }
            .padding()
        }
        .withSheetPresentation()
        .navigationDestination(for: Decision.self) { decision in
            DecisionDetailView(decision: decision)
        }
        .navigationDestination(for: ComplianceItem.self) { item in
            ComplianceDetailView(item: item)
        }
        .navigationDestination(for: ClassroomWalkthrough.self) { observation in
            ObservationDetailView(observation: observation)
        }
        .background(Color.cardBackground)
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem {
                Button {
                    navigation.presentSheet(.addDecision)
                } label: {
                    Label("Add Decision", systemImage: "lightbulb.max")
                }
            }
            ToolbarSpacer(.fixed)
            ToolbarItemGroup {
                    Button {
                        navigation.presentSheet(.editMeeting(meeting))
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
            }
            
        }
        .alert("Delete Meeting", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                model.delete(meeting)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this meeting? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Label(meeting.type.rawValue, systemImage: meeting.type.icon)
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(.orange.opacity(0.15))
                            }
                        
                        StatusBadge(status: meeting.status.statusToComplianceStatus)
                    }
                    
                    Text(meeting.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 16) {
                        Label(meeting.date.formatted(.dateTime.weekday(.wide).month().day().year()), systemImage: "calendar")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                       
                        Label(meeting.formatterDuration, systemImage: "clock")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        
                    }
                }
                
                Spacer()
                
                // Status Icon
                ZStack {
                    Circle()
                        .fill(meeting.status.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: meeting.status.icon)
                        .font(.title2.weight(.medium))
                        .foregroundStyle(meeting.status.color)
                        .symbolEffect(.bounce, value: meeting.status)
                }
            }
            
            // Status Selector
            HStack {
                Text("Status")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Menu {
                    ForEach(MeetingStatus.allCases, id: \.self) { status in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                meeting.status = status
                                isStatusChanging = true
#if !os(macOS)
                                AppTheme.impact(.light)
                                #endif
                                
                                // Reset animation state
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isStatusChanging = false
                                }
                            }
                        } label: {
                            Label(status.rawValue, systemImage: meeting.status.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(meeting.status.rawValue)
                            .font(.callout.weight(.medium))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(meeting.status.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(meeting.status.color.opacity(0.15))
                    }
                    .scaleEffect(isStatusChanging ? 1.1 : 1.0)
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 16) {
            QuickStat(
                icon: "person.2", value: "\(meeting.attendees.count)",
                label: "Attendees",
                color: .blue
            )
            if let decisions = meeting.decisions {
                QuickStat(
                    icon: "lightbulb", value: "\(decisions.count)",
                    label: "Decisions",
                    color: .purple
                )
            }
            
            if let items = meeting.complianceItems {
                QuickStat(
                    icon: "checkmark.shield", value: "\(items.count)",
                    label: "Items",
                    color: .green
                )
            }
            
            QuickStat(
                icon: "clock", value: meeting.startTime.formatted(.dateTime.hour().minute()),
                label: "Start Time",
                color: .orange
            )
        }
    }
    
    private var meetingDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Meeting Details", systemImage: "info.circle")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(
                    icon: "calendar",
                    label: "Date",
                    value: meeting.date.formatted(.dateTime.weekday(.wide).month().day().year())
                )
                
                DetailRow(
                    icon: "clock",
                    label: "Time",
                    value: "\(meeting.startTime.formatted(.dateTime.hour().minute())) - \(meeting.endTime.formatted(.dateTime.hour().minute()))"
                )
                
             
                    DetailRow(
                        icon: "timer",
                        label: "Duration",
                        value: meeting.formatterDuration
                    )
                
                
                DetailRow(
                    icon: "person.3",
                    label: "Type",
                    value: meeting.type.rawValue
                )
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Attendees", systemImage: "person.3")
                    .font(.headline)
                
                Spacer()
                
                Text("\(meeting.attendees.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(.orange.opacity(0.15))
                    }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                ForEach(meeting.attendees, id: \.self) { attendee in
                    AttendeeCard(name: attendee)
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func decisionsSection(_ decisions: [Decision]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Decisions Made", systemImage: "lightbulb")
                    .font(.headline)
                    .foregroundStyle(.purple)
                
                Spacer()
                
                Text("\(decisions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(.purple.opacity(0.15))
                    }
            }
            
            VStack(spacing: 8) {
                ForEach(decisions.prefix(3)) { decision in
                    NavigationLink(value: decision) {
                        DecisionRow(decision: decision)
                    }
                    .buttonStyle(.plain)
                }
                
                if decisions.count > 3 {
                    NavigationLink(destination: DecisionListView(decisions: Array(decisions))) {
                        HStack {
                            Text("View all \(decisions.count) decisions")
                                .font(.callout.weight(.medium))
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundStyle(.purple)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.purple.opacity(0.1))
                        }
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func complianceSection(_ items: [ComplianceItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Related Compliance Items", systemImage: "checkmark.shield")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("\(items.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(.blue.opacity(0.15))
                    }
            }
            
            VStack(spacing: 8) {
                ForEach(items.prefix(3)) { item in
                    NavigationLink(value: item) {
                        ComplianceRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
                
                if items.count > 3 {
                    Text("+ \(items.count - 3) more items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func observationsSection(_ observations: [ClassroomWalkthrough]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Classroom Observations", systemImage: "eye")
                    .font(.headline)
                    .foregroundStyle(.green)
                
                Spacer()
                
                Text("\(observations.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(.green.opacity(0.15))
                    }
            }
            
            VStack(spacing: 8) {
                ForEach(observations.prefix(2)) { observation in
                    NavigationLink(destination: ObservationDetailView(observation: observation)) {
                        ObservationRow(observation: observation)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Timeline", systemImage: "timeline.selection")
                .font(.headline)
                .foregroundStyle(.teal)
            
            VStack(alignment: .leading, spacing: 16) {
                TimelineEvent(
                    date: meeting.date,
                    title: "Meeting Scheduled",
                    icon: "calendar.badge.plus",
                    color: .blue
                )
                
                if meeting.status == .completed {
                    TimelineEvent(
                        date: meeting.endTime,
                        title: "Meeting Completed",
                        icon: "checkmark.circle",
                        color: .green
                    )
                }
                
                if let decisions = meeting.decisions, !decisions.isEmpty {
                    TimelineEvent(
                        date: meeting.date,
                        title: "\(decisions.count) Decision\(decisions.count == 1 ? "" : "s") Made",
                        icon: "lightbulb",
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview(traits: .previewData) {
    NavigationStack {
        MeetingDetailView(meeting: Meeting.samples[0])
    }
}

