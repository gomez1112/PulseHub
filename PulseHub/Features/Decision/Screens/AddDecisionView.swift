//
//  AddDecisionView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftData
import SwiftUI

struct AddDecisionView: View {
    @Environment(DataModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var title = ""
    @State private var detail = ""
    @State private var rationale = ""
    @State private var impact = ImpactLevel.medium
    @State private var nextSteps = ""
    @State private var selectedMeeting: Meeting?
    
    @Query private var meetings: [Meeting]
    @FocusState private var titleFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Decision Title", systemImage: "lightbulb")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("What did you decide?", text: $title)
                        .font(.title3)
                        .focused($titleFieldFocused)
                    Label("Details (Optional)", systemImage: "doc.text")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $detail)
                        .frame(minHeight: 80)
                        .padding(8)
                }
                
                // Rationale Section
                
                HStack {
                    Label("Rationale: ", systemImage: "brain")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Why did you make this decision?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                
                TextEditor(text: $rationale)
                    .frame(minHeight: 100)
                    .padding(8)
                
                Section {
                    Label("Impact Level", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(ImpactLevel.allCases, id: \.self) { level in
                            ImpactButton(
                                level: level,
                                isSelected: impact == level
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    impact = level
#if !os(macOS)
                                    AppTheme.selection()
                                    #endif
                                }
                            }
                        }
                    }
                }
                
                Label("Next Steps (Optional)", systemImage: "arrow.right.circle")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                TextEditor(text: $nextSteps)
                    .frame(minHeight: 80)
                    .padding(8)
                
                
                // Related Meeting
                if !meetings.isEmpty {
                    Label("Related Meeting (Optional)", systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            MeetingChip(
                                title: "None",
                                isSelected: selectedMeeting == nil
                            ) {
                                selectedMeeting = nil
                            }
                            
                            ForEach(meetings.sorted { $0.date > $1.date }.prefix(5)) { meeting in
                                MeetingChip(
                                    title: meeting.title,
                                    subtitle: meeting.date.formatted(date: .abbreviated, time: .omitted),
                                    isSelected: selectedMeeting == meeting
                                ) {
                                    selectedMeeting = meeting
                                }
                            }
                        }
                    }
                    
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Decision")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                        .disabled(!model.isValid(title: title, rationale: rationale))
                }
            }
            .onAppear {
                titleFieldFocused = true
            }
        }
    }
    
    func save() {
        model.saveDecision(title: title, detail: detail, nextStep: nextSteps, meeting: selectedMeeting, rationale: rationale, impact: impact)
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
}


#Preview(traits: .previewData) {
    NavigationStack {
        AddDecisionView()
    }
}
