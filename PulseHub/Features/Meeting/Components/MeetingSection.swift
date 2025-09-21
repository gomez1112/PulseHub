//
//  MeetingSection.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct MeetingSection: View {
    let title: String
    let meetings: [Meeting]
    let animation: Namespace.ID
    let onMeetingTap: (Meeting) -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
#if !os(macOS)
                    AppTheme.selection()
                    #endif
                }
            } label: {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: sectionIcon)
                            .font(.body.weight(.medium))
                            .foregroundStyle(sectionColor)
                        
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(title == "Today" ? sectionColor : .primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("\(meetings.count)")
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
                VStack(spacing: 8) {
                    ForEach(meetings) { meeting in
                        MeetingCard(meeting: meeting) {
                            onMeetingTap(meeting)
                        }
                        .transition(.asymmetric(
                            insertion: .push(from: .trailing),
                            removal: .push(from: .leading)
                        ))
                        .matchedGeometryEffect(id: meeting.id, in: animation)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    var sectionIcon: String {
        switch title {
            case "Today": return "sun.max.fill"
            case "Tomorrow": return "sun.haze.fill"
            case "This Week": return "calendar.circle.fill"
            case "Upcoming": return "calendar.badge.plus"
            default: return "calendar.badge.clock"
        }
    }
    
    var sectionColor: Color {
        switch title {
            case "Today": return .orange
            case "Tomorrow": return .blue
            case "This Week": return .purple
            case "Upcoming": return .green
            default: return .gray
        }
    }
}


#Preview {
    MeetingSection(
        title: "Today",
        meetings: (0..<5).map { i in Meeting(title: "Meeting \(i + 1)", date: .now, type: .admin) },
        animation: Namespace().wrappedValue,
        onMeetingTap: { _ in }
    )
}
