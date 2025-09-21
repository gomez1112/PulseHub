//
//  StatCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let trend: Trend
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isPressed.toggle()
#if !os(macOS)
                AppTheme.impact(.light)
#endif
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(color.gradient)
                            .symbolEffect(.bounce, value: isPressed)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .font(.caption.weight(.medium))
                        Text(trend.value)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(trend.color)
                    .opacity(trend.value == "—" ? 0.5 : 1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    Text("\(value)")
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
            }
            .padding()
            .cardStyle(isPressed: isPressed)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    StatCard(title: "Title", value: 20, icon: "house", color: .red, trend: .down(5))
}
