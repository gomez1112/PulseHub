//
//  StatPill.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct StatPill: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.medium))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.title3.bold())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
}


#Preview {
    StatPill(
        value: 42,
        label: "Likes",
        color: .pink,
        icon: "heart.fill"
    )
}
