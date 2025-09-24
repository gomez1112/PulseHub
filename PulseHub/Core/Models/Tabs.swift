//
//  Tabs.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftUI

/// An enumeration representing the main navigation tabs of the PulseHub application.
///
/// Each tab provides metadata such as a display title, an SF Symbol icon name, a unique customization identifier,
/// and a destination SwiftUI view representing the root content for that tab.
///
/// Tabs conform to multiple protocols for convenient usage in SwiftUI navigation and state management:
/// - `Identifiable`: so each tab can be uniquely identified by itself.
/// - `Hashable`: to support usage in collections and SwiftUI navigation.
/// - `CaseIterable`: to enumerate all available tabs.
/// - `Codable`: for persistence and serialization.
///
/// The available tabs are:
/// - `dashboard`: Shows key metrics and summaries.
/// - `compliance`: Displays compliance-related content.
/// - `meetings`: Organizes meeting schedules and details.
/// - `decision`: Facilitates decision tracking and records.
/// - `search`: Provides search functionality for the app's content.
///
/// Each tab provides:
/// - `title`: The localized display title for the tab.
/// - `icon`: The SF Symbol name for the tab's icon.
/// - `customizationID`: A unique string identifier for tab customization purposes.
/// - `destination`: The main SwiftUI view to present when the tab is selected.
/// 
enum Tabs: String, Identifiable, Hashable, CaseIterable, Codable {
    case dashboard
    case compliance
    case meetings
    case decision
    case observations
    case search
    var id: Self { self }
    
    var title: String {
        switch self {
            case .dashboard: "Dashboard"
            case .compliance: "Compliance"
            case .meetings: "Meetings"
            case .decision: "Decision"
            case .observations: "Observations"
            case .search: "Search"
        }
    }
    
    var icon: String {
        switch self {
            case .dashboard: "chart.bar"
            case .compliance: "checkmark.shield"
            case .meetings: "calendar"
            case .decision: "lightbulb"
            case .observations: "eye"
            case .search: "magnifyingglass"
        }
    }
    
    func badge(overdueItemsCount: Int, todayMeetingsCount: Int) -> Int {
        switch self {
            case .compliance:
                return overdueItemsCount
            case .meetings:
                return todayMeetingsCount
            default:
                return 0
        }
    }
    
    var customizationID: String {
        "com.transfinite.pulsehub.\(rawValue)"
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
            case .dashboard: TodayView()
            case .compliance: ComplianceView()
            case .meetings: MeetingView()
            case .decision: DecisionView()
            case .observations: ObservationView()
            case .search: SearchView()
        }
    }
}
