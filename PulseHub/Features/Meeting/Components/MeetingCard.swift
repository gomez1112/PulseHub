//
//  MeetingCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct MeetingCard: View {
    let meeting: Meeting
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Time Column
                Text(meeting.startTime, format: .dateTime.hour().minute())
                    .font(.title3.bold())
                    .foregroundStyle(meeting.date.isToday ? .orange : .primary)
                    .frame(width: 80)
                Divider()
                    .frame(height: 60)
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(meeting.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Label(meeting.type.rawValue, systemImage: meeting.type.icon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if !meeting.attendees.isEmpty {
                            Label("\(meeting.attendees.count)", systemImage: "person.2")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    
                    Label(meeting.formatterDuration, systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                }
                
                Spacer()
                
                // Status Indicator
                ZStack {
                    Circle()
                        .fill(meeting.status.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: meeting.status.icon)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(meeting.status.color)
                        .symbolEffect(.bounce, value: isPressed)
                }
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    MeetingCard(
        meeting: Meeting(title: "Meeting", type: .admin),
        action: {}
    )
}
