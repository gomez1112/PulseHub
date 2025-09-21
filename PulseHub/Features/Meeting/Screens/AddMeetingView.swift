//
//  AddMeetingView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftData
import SwiftUI

struct AddMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var title = ""
    @State private var date = Date()
    @State private var type = MeetingType.staff
    @State private var attendees: [String] = []
    @State private var newAttendee = ""
    @State private var location = ""
    @State private var agenda = ""
    @State private var duration: TimeInterval = 3600 // 1 hour default
    
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var attendeeFieldFocused: Bool
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter meeting title", text: $title)
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
                
                DatePicker("Date", selection: $date)
                
                // Duration Picker
                HStack {
                    
                    Picker("Duration", selection: $duration) {
                        Text("30 min").tag(TimeInterval(1800))
                        Text("45 min").tag(TimeInterval(2700))
                        Text("1 hour").tag(TimeInterval(3600))
                        Text("1.5 hours").tag(TimeInterval(5400))
                        Text("2 hours").tag(TimeInterval(7200))
                    }
                    .pickerStyle(.menu)
                }
                
                
                // Attendees
                VStack(alignment: .leading, spacing: 12) {
                    Label("Attendees", systemImage: "person.2")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 12) {
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
                Section("Additional Details") {
                    TextField("Location (Optional)", text: $location)
                    
                    Text("Agenda (Optional)")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $agenda)
                        .frame(minHeight: 100)
                }
                
            }
            .formStyle(.grouped)
            .navigationTitle("New Meeting")
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
        let meeting = Meeting(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            attendees: attendees,
            type: type
        )
        meeting.startTime = date
        meeting.endTime = date.addingTimeInterval(duration)
        meeting.status = .scheduled
        
        context.insert(meeting)
#if !os(macOS)
        AppTheme.impact(.medium)
#endif
        dismiss()
    }
}


#Preview {
    NavigationStack {
        AddMeetingView()
    }
}
