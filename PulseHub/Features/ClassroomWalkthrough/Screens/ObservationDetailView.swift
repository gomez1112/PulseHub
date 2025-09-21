//
//  ObservationDetailView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct ObservationDetailView: View {
    let observation: ClassroomWalkthrough
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(observation.observationType.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(observation.gradeLevel.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(observation.teacherName)
                        .font(.largeTitle.bold())
                    
                    Text(observation.subject)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Label(observation.date.formatted(), systemImage: "calendar")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                // Overall Rating
                VStack(alignment: .leading, spacing: 12) {
                    Label("Overall Rating", systemImage: "star.circle")
                        .font(.headline)
                    
                    HStack {
                        RatingView(average: Double(observation.overallRating.numericValue))
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", observation.overallAverage))
                            .font(.title2.bold())
                            .foregroundStyle(observation.overallRating.color)
                    }
                }
                .padding()
                
                // Components
                if let components = observation.components, !components.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Rubric Components", systemImage: "list.bullet.clipboard")
                            .font(.headline)
                        
                        ForEach(components) { component in
                            RubricComponentCard(component: component)
                        }
                    }
                    .padding()
                }
                
                // Follow Up
                if observation.followUpRequired {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Follow Up Required", systemImage: "exclamationmark.circle")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        if let date = observation.followUpDate {
                            Text("Scheduled for \(date.formatted())")
                                .font(.callout)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.orange.opacity(0.1))
                    }
                    .padding()
                }
            }
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}


#Preview {
    NavigationStack {
        ObservationDetailView(observation: ClassroomWalkthrough.samples[0])
    }
}
