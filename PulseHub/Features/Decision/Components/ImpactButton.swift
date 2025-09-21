//
//  ImpactButton.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct ImpactButton: View {
    let level: ImpactLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: level.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(isSelected ? .white : level.color)
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(level.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? level.color.gradient : Color.chipBackground.gradient)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview("Selected High") {
    ImpactButton(level: .high, isSelected: true, action: {})
}
