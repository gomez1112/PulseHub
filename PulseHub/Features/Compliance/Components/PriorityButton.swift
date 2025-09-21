//
//  PriorityButton.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: priority.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(isSelected ? .white : priority.color)
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(priority.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? priority.color.gradient : Color.chipBackground.gradient)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview("Selected High") {
    PriorityButton(priority: .high, isSelected: true, action: {})
}
