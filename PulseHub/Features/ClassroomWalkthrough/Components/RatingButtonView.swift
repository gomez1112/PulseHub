//
//  RatingButtonView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/13/25.
//

import SwiftUI

struct RatingButtonView: View {
    let score: DanielsonScore
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(score.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : score.color)
                    .multilineTextAlignment(.center)
                
                Text("\(score.numericValue)")
                    .font(.caption2.bold())
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? score.color.gradient : Color.chipBackground.gradient)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RatingButtonView(score: DanielsonScore.developing, isSelected: true, action: {})
}
