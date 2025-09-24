//
//  ComplianceRow.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct ComplianceRow: View {
    let item: ProjectTask
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                
                if let detail = item.detail, !detail.isEmpty {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label(item.dueDate.formatted(date: .numeric, time: .omitted), systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(item.isOverdue ? .red : .gray)
                    
                    if item.isOverdue {
                        Text("Overdue")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(Color.red.opacity(0.15))
                            }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: item.priority.icon)
                    .foregroundStyle(item.priority.color)
                    .font(.title3)
                
                Text(item.status.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(item.status == .completed ? .green : .secondary)
            }
        }
        .padding()
    }
}

#Preview {
    ComplianceRow(item: ProjectTask(title: "Submit Safety Report"))
}
