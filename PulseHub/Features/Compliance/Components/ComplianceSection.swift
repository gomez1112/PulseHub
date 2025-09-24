//
//  ComplianceSection.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct ComplianceSection: View {
    @Environment(DataModel.self) private var model
    let title: String
    let items: [ProjectTask]
    let animation: Namespace.ID
    let onItemTap: (ProjectTask) -> ()
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                    #if !os(macOS)
                    AppTheme.selection()
                    #endif
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(title == "Overdue" ? sectionColor : .primary)
                    Spacer()
                    HStack {
                        Text(items.count.formatted())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(sectionColor.opacity(0.15))
                            }
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 0 : -90))
                    }
                }
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
            if isExpanded {
                VStack {
                    ForEach(items) { task in
                        ComplianceCard(task: task) {
                            onItemTap(task)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                model.delete(task)
                            }
                        }
                        .transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
                        .matchedGeometryEffect(id: task.id, in: animation)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var sectionColor: Color {
        switch title {
            case "Overdue": .red
            case "This Week": .orange
            case "This Month": .blue
            default: .gray
        }
    }
}

#Preview(traits: .previewData) {
    @Previewable @Namespace var animation
    ComplianceSection(
        title: "Overdue",
        items: Array(repeating: ProjectTask(title: "New Task"), count: 5),
        animation: animation,
        onItemTap: { _ in }
    )
}
