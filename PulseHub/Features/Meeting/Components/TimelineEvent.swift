//  TimelineEvent.swift
//  PulseHub
//
//  Created by AI on 7/5/25.
//

import SwiftUI

struct TimelineEvent: View {
    let date: Date
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: color.opacity(0.08), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    TimelineEvent(date: .now, title: "Meeting Scheduled", icon: "calendar.badge.plus", color: .blue)
}
