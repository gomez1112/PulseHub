//
//  AnimatedStatCard.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct AnimatedStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let trend: Trend
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        StatCard(
            title: title,
            value: isVisible ? value : 0,
            icon: icon,
            color: color,
            trend: trend
        )
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    AnimatedStatCard(title: "Title", value: 20, icon: "house", color: .red, trend: .down(2), delay: 0.2)
}
