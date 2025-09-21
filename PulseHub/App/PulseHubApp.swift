//
//  PulseHubApp.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import AppIntents
import SwiftData
import SwiftUI

@main
struct PulseHubApp: App {
    private let container = ModelContainerFactory.createSharedContainer
    private let model: DataModel
    private let navigation: NavigationContext
    init() {
        let model = DataModel(container: container)
        let navigation = NavigationContext()
        self.model = model
        self.navigation = navigation
        
        AppDependencyManager.shared.add(dependency: model)
        AppDependencyManager.shared.add(dependency: navigation)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(model)
        .environment(navigation)
        .modelContainer(container)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
