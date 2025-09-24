//
//  ModelContainerFactory.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData

/// `ModelContainerFactory` is a utility structure responsible for configuring and creating 
/// `ModelContainer` instances for use with SwiftData persistent models in the PulseHub app. 
/// 
/// It provides a centralized approach to define the application's data schema, manage 
/// storage configuration (in-memory vs persistent), and generate containers for both shared 
/// and preview/testing scenarios.
///
/// - `models`: An array of all persistent model types in the application's data schema.  
/// - `schema`: The `Schema` object created from the listed models, used for container configuration.
/// - `configuration(isStoredInMemoryOnly:)`: Returns a `ModelConfiguration` for the 
///    given schema, optionally storing the data in memory only for testing or previews.
/// - `createSharedContainer`: Lazily-created, static persistent `ModelContainer` for 
///    production use, which will terminate the app if container creation fails.
/// - `createPreviewContainer()`: Creates an in-memory `ModelContainer`, pre-populated 
///    with sample data for use in SwiftUI previews or testing. Throws on failure.
///
/// Use this factory to access and initialize `ModelContainer` instances consistently 
/// throughout the app, ensuring data layer setup is centralized and easy to maintain.
@MainActor
struct ModelContainerFactory {
    static let models: [any PersistentModel.Type] = [ Meeting.self, Decision.self, Meeting.self, ClassroomWalkthrough.self, RubricComponent.self, ProjectTask.self]
    static let schema = Schema(models)
    static func configuration(isStoredInMemoryOnly: Bool) -> ModelConfiguration {
        ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
    }
    /// Lazily-created, static persistent `ModelContainer` for production use.
    ///
    /// This container is configured with the application's full data schema and is backed by
    /// on-disk persistent storage. You should use this shared container for all production
    /// data operations throughout the app to ensure a consistent and centralized data layer.
    ///
    /// - Returns: A fully-initialized `ModelContainer` instance with persistent storage.
    /// - Note: If the container cannot be created (for example, due to misconfiguration or
    ///   insufficient permissions), the application will terminate with a fatal error,
    ///   providing the underlying error's description. This guarantees that the data layer
    ///   is either fully available or the failure is clearly surfaced during app startup.
    ///
    /// Usage:
    /// ```
    /// let container = ModelContainerFactory.createSharedContainer
    /// ```
    static let createSharedContainer: ModelContainer = {
        do {
            return try ModelContainer(for: schema, configurations: configuration(isStoredInMemoryOnly: false))
        } catch {
            fatalError("Could not create model container: \(error.localizedDescription)")
        }
    }()
    
    /// Creates and returns an in-memory `ModelContainer` for use in SwiftUI previews or testing.
    ///
    /// This method configures a container using the application's data schema, with storage
    /// set to reside entirely in memory (not persisted to disk). It then pre-populates the
    /// container with sample data for all registered persistent models, as provided by each
    /// model type's `.samples` static collection. This ensures that previews and tests have
    /// access to realistic, non-empty data without affecting production storage.
    ///
    /// - Returns: An in-memory `ModelContainer` instance fully loaded with sample data.
    /// - Throws: An error if the container could not be created or if the context fails to save.
    ///
    /// Usage:
    /// ```
    /// let previewContainer = try? ModelContainerFactory.createPreviewContainer()
    /// ```
    ///
    /// Use this helper when building SwiftUI previews, UI tests, or other scenarios requiring
    /// isolated and preloaded data without impacting the user's main persistent store.
    static func createPreviewContainer() throws -> ModelContainer {
        let container = try ModelContainer(for: schema, configurations: configuration(isStoredInMemoryOnly: true))
        let context = container.mainContext

        // Insert sample data for all models
        //ComplianceItem.samples.forEach { context.insert($0) }
        Decision.samples.forEach { context.insert($0) }
        Meeting.samples.forEach { context.insert($0) }
        ClassroomWalkthrough.samples.forEach { context.insert($0) }
        RubricComponent.samples.forEach { context.insert($0) }
        
        try context.save()
        return container
    }
}
