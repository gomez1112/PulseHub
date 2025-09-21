//
//  Priority.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftUI

enum Priority: String, Identifiable, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var id: Self { self }
    
    var color: Color {
        switch self {
            case .low: .blue
            case .medium: .orange
            case .high: .red
            case .critical: .purple
        }
    }
    var icon: String {
        switch self {
            case .low: return "arrow.down.circle"
            case .medium: return "minus.circle"
            case .high: return "arrow.up.circle"
            case .critical: return "exclamationmark.triangle"
        }
    }
}
