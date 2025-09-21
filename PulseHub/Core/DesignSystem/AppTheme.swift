//
//  AppTheme.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
/// `AppTheme` provides standard UI constants and feedback generators used throughout the app.
///
/// - Constants:
///   - `cornerRadius`: The default corner radius applied to UI elements.
///   - `shadowRadius`: The default shadow radius for UI elements.
///   - `animationDuration`: The default duration for view or control animations.
///
/// - Feedback Generators:
///   - `impact(_:)`: Triggers a haptic impact using the provided feedback style. Defaults to `.light`.
///   - `selection()`: Triggers a selection-change haptic feedback.
///
/// These feedback generators are available only on Apple platforms that support UIKit (not on macOS).
enum AppTheme {
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 10
    static let animationDuration: Double = 0.3

    static func impact(_ style: HapticFeedback.ImpactStyle = .light) {
        HapticFeedback.impact(style)
    }
    
    static func selection() {
        HapticFeedback.selection()
    }
}
