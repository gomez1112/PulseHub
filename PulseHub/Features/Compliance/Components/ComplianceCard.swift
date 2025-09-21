//
//  ComplianceCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct ComplianceCard: View {
    let item: ComplianceItem
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(item.category?.title ?? "No Category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: item.priority.icon)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(item.priority.color)
                        .padding()
                        .background { Circle().fill(item.priority.color.opacity(0.15))}
                }
                HStack {
                    Label {
                        Text(LocalizedStringResource(stringLiteral: item.dueText))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(item.isOverdue ? .red : .secondary)
                    Spacer()
                    StatusBadge(status: item.status)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ComplianceCard(item: ComplianceItem.samples[0], action: {})
}
