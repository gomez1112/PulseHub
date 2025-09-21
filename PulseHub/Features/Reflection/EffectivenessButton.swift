//
//  EffectivenessButton.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct EffectivenessButton: View {
    let isEffective: Bool
    let isSelected: Bool
    var size: Size = .medium
    let action: () -> Void
    
    enum Size {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
                case .small: return 40
                case .medium: return 60
                case .large: return 80
            }
        }
        
        var iconFont: Font {
            switch self {
                case .small: return .body
                case .medium: return .title3
                case .large: return .title
            }
        }
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? (isEffective ? Color.green : Color.orange) : Color.chipBackground)
                        .frame(width: size.dimension, height: size.dimension)
                        .overlay {
                            if isSelected {
                                Circle()
                                    .stroke(isEffective ? Color.green : Color.orange, lineWidth: 2)
                                    .frame(width: size.dimension + 8, height: size.dimension + 8)
                            }
                        }
                    
                    Image(systemName: isEffective ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                        .font(size.iconFont.weight(.medium))
                        .foregroundStyle(isSelected ? .white : .gray)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                if size == .large {
                    Text(isEffective ? "Effective" : "Ineffective")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(isSelected ? (isEffective ? .green : .orange) : .secondary)
                }
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
    VStack(spacing: 20) {
        EffectivenessButton(isEffective: true, isSelected: true, action: {})
        EffectivenessButton(isEffective: false, isSelected: true, action: {})
        EffectivenessButton(isEffective: true, isSelected: false, action: {})
        EffectivenessButton(isEffective: false, isSelected: false, action: {})
    }
}



