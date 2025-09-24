//
//  ToolbarChooser.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/7/25.
//

import Foundation
import SwiftUI

/// A SwiftUI toolbar content provider that configures toolbar items dynamically based on the selected tab.
/// 
/// The `ToolbarChooser` struct uses the `Tabs` enumeration to determine which toolbar items to show for each tab.
/// It relies on the `NavigationContext` and `DataModel` environment objects to perform navigation actions
/// and manage the state of the UI, respectively.
/// 
/// ## Functionality
/// - For `.dashboard`: Displays no toolbar items.
/// - For `.compliance`: Provides a button to show statistics and another button to add a new compliance item.
/// - For `.meetings`: Offers menus for view mode and type filtering, as well as a button to add a new meeting.
/// - For `.decision`: Includes buttons for toggling analytics and adding a decision, with haptic feedback and animation.
/// - For `.search`: Adds a button to present filter options, visually indicating whether filters are active.
///
/// The toolbar content adapts to the currently selected tab, and uses transitions and feedback to enhance user interaction.
///
/// - Parameters:
///   - tab: The currently selected tab, used to determine toolbar configuration.
///
/// - Environment:
///   - `NavigationContext`: Used for navigation and presenting sheets.
///   - `DataModel`: Used for UI state and filter management.
///
struct ToolbarChooser: ToolbarContent {
    let tab: Tabs
    
    @Environment(NavigationContext.self) private var navigation
    @Environment(DataModel.self) private var model
    
    var body: some ToolbarContent {
        @Bindable var model = model
        switch tab {
            case .dashboard: dashboardToolbar
            case .compliance: complianceToolbar
            case .meetings: meetingsToolbar
            case .decision: decisionToolbar
            case .observations: observationsToolbar
            case .search: searchToolbar
        }
    }
    
    @ToolbarContentBuilder
    private var dashboardToolbar: some ToolbarContent {
        ToolbarItemGroup {
            Menu {
                ForEach(DashboardAction.allCases, id: \.self) { action in
                    Button(action.rawValue, systemImage: action.systemImage) {
                        navigation.presentSheet(action.action)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var complianceToolbar: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                withAnimation(.spring()) {
                    model.isShowingStats.toggle()
                }
            } label: {
                Image(systemName: "chart.pie")
            }
        }
        ToolbarSpacer(.fixed)
        ToolbarItem(placement: .confirmationAction) {
            Button {
                navigation.presentSheet(.addTask)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var meetingsToolbar: some ToolbarContent {
        @Bindable var model = model
        ToolbarSpacer(.flexible)
        ToolbarItem {
            Menu {
                Picker("View Mode", selection: $model.viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
            } label: {
                Image(systemName: model.viewMode.icon)
            }
        }
        ToolbarSpacer(.fixed)
        ToolbarItem {
            Menu {
                Picker("Type", selection: $model.filterType) {
                    Text("All Types").tag(MeetingType?.none)
                    ForEach(MeetingType.allCases) { type in
                        Text(type.rawValue)
                            .tag(MeetingType?.some(type))
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        ToolbarSpacer(.fixed)
        ToolbarItem {
            Button {
                navigation.presentSheet(.addMeeting)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var decisionToolbar: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    model.showAnalytics.toggle()
#if !os(macOS)
                    AppTheme.selection()
                    #endif
                }
            } label: {
                Image(systemName: "chart.pie")
            }
        }
        ToolbarSpacer(.fixed)
        ToolbarItem(placement: .automatic) {
            Button {
                navigation.presentSheet(.addDecision)
#if !os(macOS)
                AppTheme.impact(.light)
                #endif
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    @ToolbarContentBuilder
    private var observationsToolbar: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                navigation.presentSheet(.addObservation)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    @ToolbarContentBuilder
    private var searchToolbar: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    navigation.presentSheet(.filters)
#if !os(macOS)
                    AppTheme.impact(.light)
                    #endif
                }
            } label: {
                Image(systemName: model.isShowingFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .rotationEffect(.degrees(model.isShowingFilters ? 180 : 0))
            }
        }
    }
}
enum DashboardAction: String, CaseIterable {
    case meeting = "New Meeting"
    case compliance = "New Compliance"
    case decision = "New Decision"
    case observation = "New Observation"
    
    var systemImage: String {
        switch self {
            case .meeting: return "plus.circle"
            case .compliance: return "doc.badge.plus"
            case .decision: return "lightbulb.circle"
            case .observation: return "eye.circle"
        }
    }
    
    var action: SheetDestination {
        switch self {
            case .meeting: .addMeeting
            case .compliance: .addTask
            case .observation: .addObservation
            case .decision: .addDecision
        }
    }
}
private struct EmptyToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            EmptyView()
        }
    }
}

