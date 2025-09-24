//
//  EditObservationView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/13/25.
//
import SwiftUI

struct EditObservationView: View {
    @Bindable var observation: ClassroomWalkthrough
    
    @Environment(DataModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    
    @State private var teacherName = ""
    @State private var subject = ""
    @State private var gradeLevel = GradeLevel.ninth
    @State private var observationType = ObservationType.formal
    @State private var duration = 30
    @State private var overallRating = DanielsonScore.developing
    @State private var followUpRequired = false
    @State private var followUpDate: Date?
    @State private var components: [RubricComponent] = []

    
    @FocusState private var teacherNameFieldFocused: Bool
    
    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                Section("Teacher Information") {
                    TextField("Teacher Name", text: $teacherName)
                        .font(.title3)
                        .focused($teacherNameFieldFocused)
                    
                    TextField("Subject", text: $subject)
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
                
                // Rubric Components Section (only for formal and informal observations)
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
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        if components.isEmpty {
                            Text("No components added yet")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(components.enumerated(), id: \.offset) { index, component in
                                ComponentRow(
                                    component: component,
                                    onEdit: {
                                        editComponent(at: index)
                                    },
                                    onDelete: {
                                        withAnimation {
                                            removeComponent(at: index)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Observation")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: saveChanges)
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
            loadData()
        }
    }
    
    private func loadData() {
        teacherName = observation.teacherName
        subject = observation.subject
        gradeLevel = observation.gradeLevel
        observationType = observation.observationType
        duration = observation.duration
        overallRating = observation.overallRating
        followUpRequired = observation.followUpRequired
        followUpDate = observation.followUpDate
        components = observation.components ?? []
    }
    
    private func saveChanges() {
        observation.teacherName = teacherName.trimmingCharacters(in: .whitespacesAndNewlines)
        observation.subject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        observation.gradeLevel = gradeLevel
        observation.observationType = observationType
        observation.duration = duration
        observation.followUpRequired = followUpRequired
        observation.followUpDate = followUpRequired ? followUpDate : nil
        observation.components = components
        
        // Set the observation reference for each component
        components.forEach { component in
            component.observation = observation
        }
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
    
    private func editComponent(at index: Int) {
        // For now, we'll show the add component sheet
        model.isShowingAddComponent = true
    }
    private func removeComponent(at index: Int) {
        components.remove(at: index)
    }
}

#Preview(traits: .previewData) {
    EditObservationView(observation: ClassroomWalkthrough.samples[0])
}
