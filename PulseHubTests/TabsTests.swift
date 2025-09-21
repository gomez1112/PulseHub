//
//  TabsTests.swift
//  PulseHubTests
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import Testing
@testable import PulseHub

@MainActor
@Suite("Tabs Tests")
struct TabsTests {
    @Test("Tab titles are correct", arguments: [
        (Tabs.dashboard, "Dashboard"),
        (Tabs.compliance, "Compliance"),
        (Tabs.meetings, "Meetings"),
        (Tabs.decision, "Decision"),
        (Tabs.search, "Search")
    ])
    func testTabTitles(tab: Tabs, expectedTitle: String) async throws {
        #expect(tab.title == expectedTitle)
    }
    @Test("Tabs titles match cases", arguments: Tabs.allCases)
    func testTabsTitles(tab: Tabs) async throws {
        #expect(tab.title == tab.rawValue.capitalized)
    }
    
    @Test("Tabs customizationID matches format", arguments: Tabs.allCases)
    func testTabsCustomizationID(tab: Tabs) async throws {
        #expect(tab.customizationID == "com.transfinite.pulsehub.\(tab.rawValue)")
    }
}
