//
//  ScheduleWidgetView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ScheduleWidgetView: View {
    let entry: MeetingEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumScheduleView(entry: entry)
        case .systemLarge:
            LargeScheduleView(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct MediumScheduleView: View {
    let entry: MeetingEntry
    
    private var timelineGradient: LinearGradient {
        LinearGradient(
            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.orange.opacity(0.08), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar.day.timeline.left")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    
                    Text("Today's Schedule")
                        .font(.headline)
                    
                    Spacer()
                    
                    if entry.showMeetingCount {
                        Text("\(entry.meetings.count)")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.orange.opacity(0.2)))
                    }
                }
                
                if let nextMeeting = entry.nextMeeting {
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text(nextMeeting.date, format: .dateTime.hour().minute())
                                .font(.title3.bold())
                                .foregroundStyle(.orange)
                            
                            Text("Next")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 50)
                        
                        Rectangle()
                            .fill(timelineGradient)
                            .frame(width: 2)
                        
                        Button(intent: OpenMeetingIntent(meeting: nextMeeting)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextMeeting.title)
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 8) {
                                    Label(nextMeeting.type.rawValue, systemImage: "person.3")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(nextMeeting.formatterDuration)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                
                Button(intent: QuickAddIntent(itemType: .meeting)) {
                    Label("Schedule Meeting", systemImage: "plus.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .containerBackground(backgroundGradient, for: .widget)
    }
}

struct LargeScheduleView: View {
    let entry: MeetingEntry
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.orange.opacity(0.05), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today")
                            .font(.largeTitle.bold())
                        Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        VStack(spacing: 2) {
                            Text("\(entry.meetings.count)")
                                .font(.title2.bold())
                                .foregroundStyle(.orange)
                            Text("meetings")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    ForEach(entry.meetings.prefix(4), id: \.id) { meeting in
                        HStack(spacing: 12) {
                            VStack(spacing: 2) {
                                Text(meeting.date, format: .dateTime.hour().minute())
                                    .font(.callout.bold())
                                    .foregroundStyle(.orange)
                                Text(meeting.formatterDuration)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 60)
                            
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                .frame(width: 2)
                            
                            Button(intent: OpenMeetingIntent(meeting: meeting)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(meeting.title)
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 12) {
                                        Label(meeting.type.rawValue, systemImage: "person.3")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Label("\(meeting.attendees.count)", systemImage: "person.2")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.orange.opacity(0.08))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(intent: QuickAddIntent(itemType: .meeting)) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.orange)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Link(destination: URL(string: "pulsehub://meetings")!) {
                        Label("View All", systemImage: "arrow.right.circle")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .strokeBorder(Color.orange, lineWidth: 1)
                            )
                    }
                }
            }
            .padding()
        }
        .containerBackground(backgroundGradient, for: .widget)
    }
}
