//
//  StatusBadge.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct StatusBadge: View {
    let status: ComplianceStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2.weight(.medium))
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(status.color.opacity(0.15))
            }
    }
}

#Preview {
    StatusBadge(status: ComplianceStatus.completed)
}
