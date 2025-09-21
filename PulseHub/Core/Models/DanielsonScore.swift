//
//  DanielsonScore.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftUI

/// `DanielsonScore` is an enumeration representing the four performance levels
/// used in the Danielson Framework for Teaching. Each case corresponds to a
/// qualitative assessment, mapped to a numeric value and an associated color.
///
/// - ineffective: Indicates unsatisfactory performance (numeric value: 1, color: red).
/// - developing: Indicates performance that requires improvement (numeric value: 2, color: orange).
/// - effective: Indicates satisfactory performance (numeric value: 3, color: blue).
/// - highlyEffective: Indicates exemplary performance (numeric value: 4, color: green).
///
/// This type conforms to `Codable`, `CaseIterable`, and `Identifiable`,
/// making it suitable for use in SwiftUI lists and serialization.
///
/// Properties:
///   - `id`: Returns `self` for conformance to `Identifiable`.
///   - `title`: Returns the capitalized string for display.
///   - `numericValue`: Returns an `Int` score for each qualitative level.
///   - `color`: Returns a `Color` appropriate for each score, suitable for UI feedback.

enum DanielsonScore: String, Codable, CaseIterable, Identifiable {
    case ineffective      = "Ineffective"
    case developing       = "Developing"
    case effective        = "Effective"
    case highlyEffective  = "Highly Effective"

    var id: Self { self }
    
    var title: String {
        rawValue.capitalized
    }
    var numericValue: Int {
        switch self {
            case .ineffective:
                return 1
            case .developing:
                return 2
            case .effective:
                return 3
            case .highlyEffective:
                return 4
        }
    }
    var color: Color {
        switch self {
            case .ineffective: return .red
            case .developing: return .orange
            case .effective: return .blue
            case .highlyEffective: return .green
        }
    }
}
