//
//  DecisionRow.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct DecisionRow: View {
    let decision: Decision
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(decision.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                
                if let detail = decision.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let effective = decision.wasEffective {
                Image(systemName: effective ? "hand.thumbsup.circle.fill" : "hand.thumbsdown.circle.fill")
                    .foregroundStyle(effective ? .green : .orange)
            }
        }
        .padding()
    }
}


#Preview {
    List {
        DecisionRow(decision: Decision(title: "Try Pomodoro Technique", detail: "Tried for a week", wasEffective: true))
        DecisionRow(decision: Decision(title: "No Meetings Thursday", detail: "Implemented for a month", wasEffective: false))
        DecisionRow(decision: Decision(title: "Morning Standup", detail: nil, wasEffective: true))
        DecisionRow(decision: Decision(title: "Daily Walk Break", detail: "30 min at lunch", wasEffective: true))
        DecisionRow(decision: Decision(title: "Email Free Afternoons", detail: "Attempted twice", wasEffective: nil))
    }
}
