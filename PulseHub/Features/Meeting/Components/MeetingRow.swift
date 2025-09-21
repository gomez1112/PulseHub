//
//  MeetingRow.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI

struct MeetingRow: View {
    let meeting: Meeting
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meeting.title)
                    .font(.headline)
                Text(meeting.date, format: .dateTime.month().day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(meeting.type.rawValue)
                .font(.caption)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12))
        }
        .padding(.vertical)
    }
}

#Preview {
    MeetingRow(meeting: Meeting.samples[0])
}
