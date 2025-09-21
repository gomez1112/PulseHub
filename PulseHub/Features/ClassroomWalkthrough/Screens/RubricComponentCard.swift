//
//  RubricComponentCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct RubricComponentCard: View {
    let component: RubricComponent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(component.componentNumber): \(component.detail)")
                        .font(.callout.weight(.medium))
                    
                    Text(component.domain.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                RatingView(average: Double(component.score.numericValue))
            }
            
            if let comments = component.comments {
                Text(comments)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
    }
}


#Preview {
    RubricComponentCard(component: RubricComponent(
        domain: .classroomEnvironment, componentNumber: "2e",
        detail: "Demonstrates clear reasoning and evidence.",
        score: .developing,
        comments: "Excellent work! Well supported arguments."
    ))
}
