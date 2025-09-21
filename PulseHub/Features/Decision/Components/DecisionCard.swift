//
//  DecisionCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct DecisionCard: View {
    let decision: Decision
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(decision.title)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if let detail = decision.detail {
                            Text(detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: decision.impact.icon)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(decision.impact.color)
                        .padding(6)
                        .background {
                            Circle()
                                .fill(decision.impact.color.opacity(0.15))
                        }
                }
                
                HStack {
                    Label(decision.dateMade.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    if let effective = decision.wasEffective {
                        HStack(spacing: 4) {
                            Image(systemName: effective ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                .font(.caption)
                            Text(effective ? "Effective" : "Ineffective")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(effective ? .green : .orange)
                    } else {
                        Label("Pending Review", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview("Sample") {
    DecisionCard(
        decision: Decision(
            title: "Launch New Initiative",
            detail: "Kick off the Q3 marketing push across all teams.",
            dateMade: .now,
            wasEffective: nil
        ),
        action: {}
    )
}
