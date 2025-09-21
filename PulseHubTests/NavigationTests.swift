//
//  NavigationTests.swift
//  PulseHubTests
//
//  Created by Gerard Gomez on 7/3/25.
//

import Testing
@testable import PulseHub

@MainActor
@Suite("PulseHub")
struct NavigationTests {
    let navigation = NavigationContext()
    
    @Test("NavigationContext default is dashboard")
    func testNavigationContextDefault() async throws {
        #expect(navigation.selectedTab == .dashboard)
    }
    
    @Test("NavigationContext navigate works")
    func testNavigationContextNavigate() async throws {
        navigation.navigate(to: .meetings)
        #expect(navigation.selectedTab == .meetings)
    }
}
