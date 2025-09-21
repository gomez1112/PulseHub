//
//  ComplianceWidgetView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct ComplianceWidgetView: View {
    let entry: ComplianceEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallComplianceView(entry: entry)
        case .systemMedium:
            MediumComplianceView(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct SmallComplianceView: View {
    let entry: ComplianceEntry
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                entry.overdueCount > 0 ? Color.red.opacity(0.15) : Color.blue.opacity(0.15),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(entry.overdueCount > 0 ? .red : .blue)
                
                Spacer()
                
                if entry.overdueCount > 0 {
                    Text("\(entry.overdueCount)")
                        .font(.title2.bold())
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                if entry.overdueCount > 0 {
                    Label("\(entry.overdueCount) Overdue", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                }
                
                Label("\(entry.todayCount) Due Today", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            
            Button(intent: QuickAddIntent(itemType: .compliance)) {
                HStack {
                    Text("Add New")
                        .font(.caption2.weight(.semibold))
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
        }
    }
    
    var body: some View {
        mainContent
            .padding()
            .containerBackground(backgroundGradient, for: .widget)
    }
}

struct MediumComplianceView: View {
    let entry: ComplianceEntry
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                entry.overdueCount > 0 ? Color.red.opacity(0.1) : Color.blue.opacity(0.1),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var mainContent: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.title)
                        .foregroundStyle(entry.overdueCount > 0 ? .red : .blue)
                    
                    Text("Compliance")
                        .font(.headline)
                }
                
                Spacer()
                
                if entry.overdueCount > 0 {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("\(entry.overdueCount) Overdue")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                }
                
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("\(entry.todayCount) Due Today")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .frame(height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(entry.items.prefix(2)), id: \.id) { (item: ComplianceItem) in
                    let entity = ComplianceItemEntity(complianceItem: item)
                    Button(intent: OpenComplianceItemIntent(item: entity)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                
                                Text(item.category?.title ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if item.isOverdue {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            } else {
                                Button(intent: MarkComplianceCompleteIntent(item: entity)) {
                                    Image(systemName: "circle")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var body: some View {
        mainContent
            .padding()
            .containerBackground(backgroundGradient, for: .widget)
    }
}
