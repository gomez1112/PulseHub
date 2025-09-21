import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

extension Color {
    /// Cross-platform equivalent of system background color
    static var systemBackgroundCompat: Color {
        #if os(iOS) || os(tvOS) || os(visionOS)
        return Color(uiColor: .systemBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        // Fallback for other platforms
        return Color.white
        #endif
    }

    /// Cross-platform equivalent of secondary system background color
    static var secondarySystemBackgroundCompat: Color {
        #if os(iOS) || os(tvOS) || os(visionOS)
        return Color(uiColor: .secondarySystemBackground)
        #elseif os(macOS)
        return Color(nsColor: .underPageBackgroundColor)
        #else
        // Fallback for other platforms
        return Color.white.opacity(0.9)
        #endif
    }
}
