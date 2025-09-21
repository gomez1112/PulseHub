//
//  TimeRange.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation

enum TimeRange: String, CaseIterable {
    case today = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var icon: String {
        switch self {
            case .today: return "sun.max"
            case .week: return "calendar.day.timeline.left"
            case .month: return "calendar"
            case .year: return "calendar.circle"
        }
    }
}
