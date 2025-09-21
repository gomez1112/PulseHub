//
//  DetailRow.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/6/25.
//

import Foundation

import SwiftUI

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.callout.weight(.medium))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    DetailRow(icon: "house", label: "House", value: "20")
}
