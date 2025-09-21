//
//  Platform.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/14/25.
//

import Foundation
import SwiftUI

// MARK: - Platform Detection
enum Platform {
    static var isMac: Bool {
#if os(macOS)
        return true
#else
        return false
#endif
    }
    
    static var isIOS: Bool {
#if os(iOS)
        return true
#else
        return false
#endif
    }
    
    static var isTVOS: Bool {
#if os(tvOS)
        return true
#else
        return false
#endif
    }
    
    static var supportsHaptics: Bool {
#if canImport(UIKit) && !os(tvOS)
        return true
#else
        return false
#endif
    }
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    enum ImpactStyle {
        case light
        case medium
        case heavy
        case soft
        case rigid
        
#if canImport(UIKit)
        var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
                case .light: return .light
                case .medium: return .medium
                case .heavy: return .heavy
                case .soft: return .soft
                case .rigid: return .rigid
            }
        }
#endif
    }
    
    static func impact(_ style: ImpactStyle = .light) {
        guard Platform.supportsHaptics else { return }
        
#if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style.uiKitStyle)
        generator.impactOccurred()
#endif
    }
    
    static func selection() {
        guard Platform.supportsHaptics else { return }
        
#if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
#endif
    }
}

// MARK: - View Extensions for Platform-Specific Modifiers
#if os(iOS) || os(visionOS)
extension View {
    /// Applies navigation bar title display mode only on non-macOS platforms
    func adaptiveNavigationBarTitleDisplayMode(_ mode: NavigationBarItem.TitleDisplayMode) -> some View {
        self.navigationBarTitleDisplayMode(mode)
    }
}
#else
extension View {
    /// On macOS and other platforms, does nothing
    func adaptiveNavigationBarTitleDisplayMode(_ mode: Any) -> some View {
        self
    }
}
#endif

extension View {    
    /// Triggers haptic feedback on supported platforms
    func withHapticFeedback(style: HapticFeedback.ImpactStyle = .light, on trigger: Bool) -> some View {
        onChange(of: trigger) { _, newValue in
            if newValue {
                HapticFeedback.impact(style)
            }
        }
    }
    
    /// Triggers selection haptic feedback
    func withSelectionHaptic(on trigger: Bool) -> some View {
        onChange(of: trigger) { _, newValue in
            if newValue {
                HapticFeedback.selection()
            }
        }
    }
}
extension Color {
    static var chipBackground: Color {
        #if os(iOS)
        return Color(.systemGray5)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color.gray
        #endif
    }
    
    static var cardBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
}

