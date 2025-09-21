//
//  AttendeeCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct AttendeeCard: View {
    let name: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange.gradient)
            
            Text(name)
                .font(.callout.weight(.medium))
                .lineLimit(1)
            
            Spacer()
        }
        .padding()

    }
}

#Preview {
    AttendeeCard(name: "Gerard")
}
