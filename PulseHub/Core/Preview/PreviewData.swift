//
//  PreviewData.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//


import Foundation
import SwiftData
import SwiftUI

/// A preview modifier used to configure the SwiftUI preview environment with mock data and dependencies.
///
/// `PreviewData` is designed to facilitate SwiftUI previews by providing a shared `ModelContainer`
/// populated with sample data, and injecting relevant dependencies into the environment.
/// 
/// Usage:
/// Apply the `.previewData` trait in your preview providers to simulate a real runtime environment.
///
/// - The `makeSharedContext()` method creates and returns a preview `ModelContainer`, typically
///   containing in-memory sample data.
/// - The `body(content:context:)` method applies the model container to the view hierarchy and
///   injects supporting environment objects, such as the main data model and navigation context.
/// - Used in conjunction with the `PreviewTrait.previewData` extension for concise modifier application.

struct PreviewData: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        try ModelContainerFactory.createPreviewContainer()
    }
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
            .environment(DataModel(container: context))
            .environment(NavigationContext())
    }
}
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var previewData: Self = .modifier(PreviewData())
}
