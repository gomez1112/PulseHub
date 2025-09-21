// EditMeetingView.swift
// PulseHub
//
// Created by Gerard Gomez on 7/5/25.

import SwiftData
import SwiftUI

struct EditMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var meeting: Meeting
    
    @State private var title = ""
    @State private var date = Date()
    @State private var type = MeetingType.parent
    @State private var attendees: [String] = []
    @State private var newAttendee = ""
    @State private var duration: TimeInterval = 0
    
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var attendeeFieldFocused: Bool
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title & Type") {
                    TextField("Meeting Title", text: $title)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .focused($titleFieldFocused)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(MeetingType.allCases) { meetingType in
                            MeetingTypeCard(
                                type: meetingType,
                                isSelected: type == meetingType
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    type = meetingType
#if !os(macOS)
                                    AppTheme.selection()
                                    #endif
                                }
                            }
                        }
                    }
                }
                
                Section("When & Duration") {
                    DatePicker("Date", selection: $date)
                    
                    // Duration Picker
                    HStack {
                        Text("Duration")
                            .font(.callout.weight(.medium))
                        Spacer()
                        Picker("Duration", selection: $duration) {
                            Text("30 min").tag(TimeInterval(1800))
                            Text("45 min").tag(TimeInterval(2700))
                            Text("1 hour").tag(TimeInterval(3600))
                            Text("1.5 hours").tag(TimeInterval(5400))
                            Text("2 hours").tag(TimeInterval(7200))
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Attendees") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TextField("Add attendee name", text: $newAttendee)
                                .focused($attendeeFieldFocused)
                                .onSubmit {
                                    addAttendee()
                                }
                            Button("Add") {
                                addAttendee()
                            }
                            .disabled(newAttendee.isEmpty)
                        }
                        if !attendees.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(attendees, id: \.self) { attendee in
                                        AttendeeChip(name: attendee) {
                                            withAnimation {
                                                attendees.removeAll { $0 == attendee }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Meeting")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: saveMeeting)
                        .disabled(!isValid)
                }
            }
        }
        .onAppear {
            titleFieldFocused = true
            title = meeting.title
            date = meeting.date
            type = meeting.type
            attendees = meeting.attendees
            duration = meeting.duration.value
        }
    }
    
    private func addAttendee() {
        let trimmed = newAttendee.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !attendees.contains(trimmed) {
            withAnimation {
                attendees.append(trimmed)
                newAttendee = ""
#if !os(macOS)
                AppTheme.impact(.light)
                #endif
            }
        }
    }
    
    private func saveMeeting() {
        meeting.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        meeting.date = date
        meeting.type = type
        meeting.attendees = attendees
        meeting.startTime = date
        meeting.endTime = date.addingTimeInterval(duration)
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditMeetingView(meeting: Meeting.samples[0])
    }
}
