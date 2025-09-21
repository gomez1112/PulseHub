//
//  MeetingTypeCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct MeetingTypeCard: View {
    let type: MeetingType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .orange)
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(type.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.orange.gradient : Color.chipBackground.gradient)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    MeetingTypeCard(type: .parent, isSelected: true, action: {})
}
