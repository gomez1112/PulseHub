//
//  AddObservationView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

import SwiftData
import SwiftUI

struct AddObservationView: View {
    @Environment(DataModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var gradeLevel = GradeLevel.ninth
    @State private var observationType = ObservationType.formal
    @State private var duration = 30
    @State private var overallRating = DanielsonScore.developing
    @State private var followUpRequired = false
    @State private var followUpDate: Date?
    @State private var selectedMeeting: Meeting?
    @State private var components: [RubricComponent] = []

    @State private var isShowingEditComponent = false
    @State private var componentToEdit: RubricComponent?
    
    @Query private var meetings: [Meeting]
    
    @FocusState private var teacherNameFieldFocused: Bool
    
    
    
    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                Section("Teacher Information") {
                    Label("Teacher Name", systemImage: "person.circle")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter teacher's name", text: $model.teacherName)
                        .font(.title3)
                        .focused($teacherNameFieldFocused)
                    
                    TextField("Subject", text: $model.subject)
                        .font(.callout)
                }
                
                Section("Observation Details") {
                    Picker("Grade Level", selection: $gradeLevel) {
                        ForEach(GradeLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Observation Type", selection: $observationType) {
                        ForEach(ObservationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Duration")
                            .font(.callout.weight(.medium))
                        
                        Spacer()
                        
                        Picker("Duration", selection: $duration) {
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                            Text("45 min").tag(45)
                            Text("60 min").tag(60)
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Overall Rating") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(DanielsonScore.allCases, id: \.self) { score in
                            RatingButtonView(
                                score: score,
                                isSelected: overallRating == score
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    overallRating = score
#if !os(macOS)
                                    AppTheme.selection()
                                    #endif
                                }
                            }
                        }
                    }
                }
                
                Section("Follow Up") {
                    Toggle("Follow-up Required", isOn: $followUpRequired)
                    
                    if followUpRequired {
                        DatePicker("Follow-up Date", selection: Binding(
                            get: { followUpDate ?? Date() },
                            set: { followUpDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                if observationType == .formal || observationType == .informal {
                    Section {
                        HStack {
                            Label("Rubric Components", systemImage: "list.bullet.clipboard")
                                .font(.headline)
                            Spacer()
                            Button {
                                model.isShowingAddComponent = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                            .foregroundStyle(.tint)
                            .buttonStyle(.plain)
                        }
                    }
                    if components.isEmpty {
                        ContentUnavailableView {
                            Label("No Components added yet", systemImage: "list.bullet.clipboard")
                        } actions: {
                            Button {
                                model.isShowingAddComponent = true
                            } label: {
                                Text("Add Component")
                            }
                            .foregroundStyle(.tint)
                            .buttonStyle(.plain)
                        }

                    } else {
                        ForEach(components.enumerated(), id: \.offset) { index, component in
                            ComponentRow(component: component) {
                                componentToEdit = component
                            } onDelete: {
                                withAnimation {
                                    removeComponent(at: index)
                                }
                            }
                            .sheet(item: $componentToEdit) { component in
                                EditComponentView(component: component) { updatedComponent in
                                    if let index = components.firstIndex(where: { $0.id == updatedComponent.id }) {
                                        components[index] = updatedComponent
                                    }
                                }
                            }
                        }
                    }
                }
                if !meetings.isEmpty {
                    Section("Related Meeting (Optional)") {
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
            }
            .formStyle(.grouped)
            .navigationTitle("New Observation")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                        .disabled(!model.isValid)
                }
            }
        }
        .sheet(isPresented: $model.isShowingAddComponent) {
            AddComponentView { component in
                withAnimation {
                    components.append(component)
                }
            }
        }
        .onAppear {
            teacherNameFieldFocused = true
            followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        }
    }
    private func save() {
        model.saveObservation(teacherName: model.teacherName, components: components, subject: model.subject, gradeLevel: gradeLevel, observationType: observationType, duration: duration, overallRating: overallRating, followUpRequired: followUpRequired, followUpDate: followUpDate, selectedMeeting: selectedMeeting)
        components.forEach { model.save($0)}
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
    private func editComponent(at index: Int) {
        // For now, we'll show the add component sheet with existing data
        isShowingEditComponent = true
    }
    private func removeComponent(at index: Int) {
        components.remove(at: index)
    }
}

#Preview(traits: .previewData) {
    AddObservationView()
}
