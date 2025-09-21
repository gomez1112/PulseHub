//
//  TimelineItem.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct TimelineItem: View {
    let meeting: Meeting
    let isFirst: Bool
    let isLast: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 2)
                        .frame(height: 20)
                }
                
                Circle()
                    .fill(meeting.status == .completed ? Color.green : Color.blue)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.date.formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                MeetingCard(meeting: meeting, action: action)
                    .padding(.bottom, isLast ? 0 : 20)
            }
        }
    }
}

#Preview {
    TimelineItem(meeting: Meeting.samples[0], isFirst: true, isLast: false, action: {})
}
#Preview {
    TimelineItem(meeting: Meeting.samples[0], isFirst: true, isLast: true, action: {})
}
#Preview {
    TimelineItem(meeting: Meeting.samples[0], isFirst: false, isLast: true, action: {})
}
