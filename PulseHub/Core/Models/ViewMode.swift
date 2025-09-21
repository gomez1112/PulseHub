//
//  ViewMode.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/7/25.
//

import Foundation

/// `ViewMode` represents the different display modes available within the PulseHub application.
/// 
/// - `list`: Presents data in a traditional list format.
/// - `calendar`: Displays data in a calendar-oriented view.
/// - `timeline`: Shows data along a chronological timeline.
///
/// Each mode provides an associated `icon` string suitable for display in user interface elements.
enum ViewMode: String, CaseIterable {
    case list = "List"
    case calendar = "Calendar"
    case timeline = "Timeline"
    
    var icon: String {
        switch self {
            case .list: return "list.bullet"
            case .calendar: return "calendar"
            case .timeline: return "arrow.triangle.2.circlepath"
        }
    }
}
