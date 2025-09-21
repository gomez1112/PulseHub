//
//  TodayMeetingCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct TodayMeetingCard: View {
    let meeting: Meeting
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(meeting.startTime, format: .dateTime.hour().minute())
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                    
                    Spacer()
                    
                    Image(systemName: meeting.type.icon)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Circle().fill(Color.orange))
                }
                
                Text(meeting.title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    if !meeting.attendees.isEmpty {
                        Label("\(meeting.attendees.count)", systemImage: "person.2")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(meeting.formatterDuration)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                }
            }
            .padding()
            .frame(width: 160)
            .cardStyle(isPressed: isPressed)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(meeting.status == .inProgress ? Color.green : Color.blue)
                    .frame(width: 8, height: 8)
                    .offset(x: -8, y: 8)
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }
    }
}

#Preview {
    TodayMeetingCard(meeting: Meeting.samples[0], action: {})
}
