//
//  ComplianceCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct ComplianceCard: View {
    let task: ProjectTask
    
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Image(systemName: task.priority.icon)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(task.priority.color)
                        .padding()
                        .background { Circle().fill(task.priority.color.opacity(0.15))}
                }
                HStack {
                    Label {
                        Text(LocalizedStringResource(stringLiteral: task.dueText))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(task.isOverdue ? .red : .secondary)
                    Spacer()
                    StatusBadge(status: task.status)
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
    ComplianceCard(task: ProjectTask(title: "New Task"), action: {})
}
