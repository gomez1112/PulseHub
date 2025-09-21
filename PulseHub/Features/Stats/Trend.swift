//
//  Trend.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation
import SwiftUI

enum Trend {
    case up(Int)
    case down(Int)
    case neutral
    
    var icon: String {
        switch self {
            case .up: return "arrow.up.circle.fill"
            case .down: return "arrow.down.circle.fill"
            case .neutral: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
        }
    }
    
    var value: String {
        switch self {
            case .up(let val): return "+\(val)"
            case .down(let val): return "-\(val)"
            case .neutral: return "—"
        }
    }
}
