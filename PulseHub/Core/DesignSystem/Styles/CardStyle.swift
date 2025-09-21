//
//  CardStyle.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI

/// A view modifier that applies a card-like visual style to a view, including background, corner radius, shadow, and interactive scaling.
///
/// The `CardStyle` modifier uses a rounded rectangle with a continuous corner radius (as defined by `AppTheme.cornerRadius`) and a subtle shadow (adjusted for dark mode and pressed state).
///
/// - When the view is pressed (`isPressed == true`), the card slightly scales down and the shadow becomes smaller and closer.
/// - The background color is derived from the system background to adapt to the current color scheme.
/// - Animates between pressed and non-pressed states using a spring animation for a smooth, interactive feel.
///
/// Use this modifier to create visually consistent, interactive card surfaces across your app.
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(
                        color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                        radius: isPressed ? 2 : AppTheme.shadowRadius,
                        y: isPressed ? 1 : 5
                    )
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}


#Preview {
    Text("Preview Card")
        .modifier(CardStyle())
}
