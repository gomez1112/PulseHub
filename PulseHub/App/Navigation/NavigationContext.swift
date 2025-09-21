//
//  NavigationContext.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//


import Foundation
import Observation
import SwiftUI

/// `NavigationContext` manages navigation state and transitions within the app.
/// 
/// - Manages the currently selected tab (`selectedTab`) using the `Tabs` enum.
/// - Maintains a `NavigationPath` (`path`) for stack-based navigation, enabling push/pop of navigation destinations.
/// - Handles presentation of modal sheets via the `presentedSheet` property, which uses the `SheetDestination` enum.
///
/// ## Responsibilities
/// - Changing the selected tab within the app using `navigate(to tab:)`.
/// - Navigating to a specific destination (screen) via `navigate(to destination:)`.
/// - Popping the latest navigation destination from the stack with `pop()`.
/// - Resetting navigation and sheet state using `reset()`.
/// - Presenting and dismissing sheets with `presentSheet(_:)` and `dismissSheet()`.
///
/// ## Usage
/// - Used as a shared, observable object in SwiftUI views to coordinate navigation.
/// - Allows programmatic navigation control, including modal sheet presentation.
///
/// ## Dependencies
/// - Relies on `Tabs`, `NavigationDestination`, and `SheetDestination` enums.
/// - All navigation destinations and sheets must conform to `Identifiable` for integration with SwiftUI APIs.
///
/// ## Example
/// ```swift
/// @Environment(NavigationContext.self) var nav
/// nav.navigate(to: .meeting(meeting))
/// nav.presentSheet(.editMeeting(meeting))
/// nav.dismissSheet()
/// ```
@Observable
final class NavigationContext {
    var selectedTab: Tabs = .dashboard
    var path = NavigationPath()
    var presentedSheet: SheetDestination?
    
    func navigate(to tab: Tabs) {
        selectedTab = tab
    }
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    func reset() {
        path = NavigationPath()
        presentedSheet = nil
    }
    
    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }
    func dismissSheet() {
        presentedSheet = nil
    }
}
enum NavigationDestination: Identifiable, Hashable {
    case meeting(Meeting)
    case decision(Decision)
    case compliance(ComplianceItem)
    case observation(ClassroomWalkthrough)
    // Add more cases as needed
    
    var id: String {
        switch self {
            case .meeting(let m): return "meeting-\(m.title)"
            case .decision(let d): return "decision-\(d.title)"
            case .compliance(let c): return "compliance-\(c.title)"
            case .observation(let o): return "observation-\(o.teacherName)"
        }
    }
}
// Enum for all sheets in the app
enum SheetDestination: Identifiable {
    
    case addCompliance
    case editCompliance(ComplianceItem)
    case addMeeting
    case editMeeting(Meeting)
    case addDecision
    case editDecision(Decision)
    case addObservation
    case editObservation(ClassroomWalkthrough)
    case reflection(Decision)
    case filters
    
    var id: String {
        switch self {
            case .addCompliance: return "addCompliance"
            case .editCompliance(let item): return "editCompliance_\(item.id)"
            case .addMeeting: return "addMeeting"
            case .editMeeting(let meeting): return "editMeeting_\(meeting.id)"
            case .addDecision: return "addDecision"
            case .editDecision(let decision): return "editDecision_\(decision.id)"
            case .addObservation: return "addObservation"
            case .editObservation(let observation): return "editObservation_\(observation.id)"
            case .reflection(let decision): return "reflection_\(decision.id)"
            case .filters: return "filters"
        }
    }
    var presentationDetents: Set<PresentationDetent> {
        switch self {
            case .filters:
                return [.medium, .large]
            default:
                return [.large]
        }
    }
}


