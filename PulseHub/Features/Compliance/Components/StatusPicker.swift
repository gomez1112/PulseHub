//
//  StatusPicker.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct StatusPicker: View {
    @Binding var selection: ComplianceStatus
    
    var body: some View {
        Menu {
            ForEach(ComplianceStatus.allCases) { status in
                Button {
                    withAnimation {
                        selection = status
                    }
                } label: {
                    Label(status.rawValue, systemImage: selection.icon)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: selection.icon)
                    .font(.caption.weight(.medium))
                Text(selection.rawValue)
                    .font(.callout.weight(.medium))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(selection.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(selection.color.opacity(0.15))
            }
        }
    }
}

#Preview {
    StatusPicker(selection: .constant(.cancelled))
}
