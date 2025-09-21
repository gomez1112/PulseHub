//
//  ComplianceStatPill.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct ComplianceStatPill: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value.formatted())
                .font(.title2.bold())
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(color.opacity(0.1))
        }
    }
}

#Preview {
    ComplianceStatPill(value: 20, label: "Label", color: .green)
}
