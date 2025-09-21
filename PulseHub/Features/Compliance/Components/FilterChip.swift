//
//  FilterChip.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    var color: Color = .accentColor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption.weight(.medium))
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.semibold))
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(isSelected ? color : Color.chipBackground)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview("Default") {
    FilterChip(title: "Unread", isSelected: true, count: 3, color: .blue, action: {})
}
