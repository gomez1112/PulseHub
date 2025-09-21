//
//  ObservationRow.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct ObservationRow: View {
    let observation: ClassroomWalkthrough
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(observation.teacherName)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                
                Text(observation.subject)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    RatingView(average: Double(observation.overallRating.numericValue))
                    Text("• \(observation.gradeLevel.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(observation.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                if observation.followUpRequired {
                    Label("Follow-up", systemImage: "exclamationmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ObservationRow(observation: ClassroomWalkthrough.samples[0])
}
