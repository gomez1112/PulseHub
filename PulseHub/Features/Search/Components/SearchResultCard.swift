//
//  SearchResultCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI

struct SearchResultCard: View {
    let item: SearchResultItem

    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack(spacing: 12) {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(iconColor.gradient)
                        .symbolEffect(.bounce, value: isPressed)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Label(date, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(badgeColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .fill(badgeColor.opacity(0.15))
                                }
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isPressed ? 90 : 0))
            }
            .padding(12)
            .cardStyle(isPressed: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }
    }
    
    private var icon: String {
        switch item {
            case .compliance: return "checkmark.shield.fill"
            case .meeting: return "calendar.circle.fill"
            case .decision: return "lightbulb.fill"
            case .observation: return "eye.fill"
        }
    }
    
    private var iconColor: Color {
        switch item {
            case .compliance: return .blue
            case .meeting: return .orange
            case .decision: return .purple
            case .observation: return .green
        }
    }
    
    private var title: String {
        switch item {
            case .compliance(let item): return item.title
            case .meeting(let meeting): return meeting.title
            case .decision(let decision): return decision.title
            case .observation(let obs): return obs.teacherName
        }
    }
    
    private var subtitle: String {
        switch item {
            case .compliance(let item): return item.category?.title ?? "No Category"
            case .meeting(let meeting): return meeting.type.rawValue
            case .decision(let decision): return decision.detail ?? "No details"
            case .observation(let obs): return obs.subject
        }
    }
    
    private var date: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        
        let targetDate: Date
        switch item {
            case .compliance(let item): targetDate = item.dueDate
            case .meeting(let meeting): targetDate = meeting.date
            case .decision(let decision): targetDate = decision.dateMade
            case .observation(let obs): targetDate = obs.date
        }
        
        return formatter.localizedString(for: targetDate, relativeTo: Date())
    }
    
    private var badge: String? {
        switch item {
            case .compliance(let item):
                return item.isOverdue ? "Overdue" : nil
            case .meeting(let meeting):
                return meeting.status.rawValue
            case .decision(let decision):
                guard let effective = decision.wasEffective else { return nil }
                return effective ? "Effective" : "Ineffective"
            case .observation(let obs):
                return obs.overallRating.rawValue
        }
    }
    
    private var badgeColor: Color {
        switch item {
            case .compliance(let item):
                return item.isOverdue ? .red : .green
            case .meeting:
                return .blue
            case .decision(let decision):
                guard let effective = decision.wasEffective else { return .gray }
                return effective ? .green : .orange
            case .observation(let obs):
                switch obs.overallRating {
                    case .ineffective: return .red
                    case .developing: return .orange
                    case .effective: return .blue
                    case .highlyEffective: return .green
                }
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch item {
            case .compliance(let item):
                ComplianceDetailView(item: item)
            case .meeting(let meeting):
               MeetingDetailView(meeting: meeting)
            case .decision(let decision):
                Text("DecisionDetailView")
               DecisionDetailView(decision: decision)
            case .observation(let obs):
               ObservationDetailView(observation: obs)
        }
    }
}

#Preview {
    SearchResultCard(item: .compliance(ComplianceItem(title: "Test Rule", category: ComplianceCategory(), dueDate: Date())))
}
