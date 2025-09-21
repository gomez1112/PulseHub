//
//  AttendeeChip.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct AttendeeChip: View {
    let name: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.circle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
            
            Text(name)
                .font(.callout.weight(.medium))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(.orange.opacity(0.15))
        }
    }
}


#Preview {
    AttendeeChip(name: "Jane Doe", onDelete: {})
}
