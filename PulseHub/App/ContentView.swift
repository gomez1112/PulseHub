//
//  ContentView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI

struct ContentView: View {
    #if !os(macOS) && !os(tvOS)
    @AppStorage("sidebarCustomizations") var tabViewCustomization: TabViewCustomization
    #endif
    @Environment(DataModel.self) private var model
    @Environment(NavigationContext.self) private var navigation
    
    var body: some View {
        @Bindable var navigation = navigation
        NavigationStack(path: $navigation.path) {
            TabView(selection: $navigation.selectedTab) {
                ForEach(Tabs.allCases) { tab in
                    Tab(tab.title, systemImage: tab.icon, value: tab, role: tab == .search ? .search : nil) {
                        tab.destination
                    }
                    .customizationID(tab.customizationID)
                    .badge(tab.badge(overdueItemsCount: model.overdueItemsCount, todayMeetingsCount: model.todayMeetingsCount))
                }
            }
            .frame(minWidth: 250, minHeight: 250)
            .tabViewStyle(.sidebarAdaptable)
            .toolbar {
                ToolbarChooser(tab: navigation.selectedTab)
            }
            #if !os(macOS)
            .tabViewCustomization($tabViewCustomization)
            #endif
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .withSheetPresentation()
        
    }
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
            case .meeting(let meeting):
                MeetingDetailView(meeting: meeting)
            case .decision(let decision):
                DecisionDetailView(decision: decision)
            case .task(let task):
                ComplianceDetailView(task: task)
            case .observation(let observation):
                ObservationDetailView(observation: observation)
        }
    }
}
// MARK: - Sheet Presentation Modifier
struct SheetPresentationModifier: ViewModifier {
    @Environment(NavigationContext.self) private var navigation
    
    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(
                get: { navigation.presentedSheet },
                set: { navigation.presentedSheet = $0 }
            )) { sheet in
                sheetContent(for: sheet)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(AppTheme.cornerRadius)
            }
    }
    
    @ViewBuilder
    private func sheetContent(for sheet: SheetDestination) -> some View {
        switch sheet {
            case .addTask:
                AddComplianceView()
            case .editTask(let item):
                EditComplianceView(item: item)
            case .addMeeting:
                AddMeetingView()
            case .editMeeting(let meeting):
                EditMeetingView(meeting: meeting)
            case .addDecision:
                EditDecisionView(decision: nil)
            case .editDecision(let decision):
                EditDecisionView(decision: decision)
            case .addObservation:
                AddObservationView()
            case .editObservation(let observation):
                EditObservationView(observation: observation)
            case .reflection(let decision):
                ReflectionView(decision: decision)
            case .filters:
                FilterSheet()
        }
    }
}

// MARK: - View Extension
extension View {
    /// Adds sheet presentation capability using NavigationContext
    func withSheetPresentation() -> some View {
        modifier(SheetPresentationModifier())
    }
}

#Preview(traits: .previewData) {
    ContentView()
}
