
import SwiftData
import Testing
@testable import PulseHub

@MainActor
@Suite("PulseHub")
struct PulseHubTests {
    @Suite("SwiftData Tests")
    @MainActor
    struct SwiftDataTests {
        @Test("Can create preview ModelContainer and insert sample data")
        func testModelContainerAndSampleInsert() async throws {
            let container = try ModelContainerFactory.createPreviewContainer()
            let context = container.mainContext
            
            try expectSample(ComplianceCategory.self, in: context)
            try expectSample(ComplianceItem.self, in: context)
            try expectSample(Decision.self, in: context)
            try expectSample(Meeting.self, in: context)
            try expectSample(ClassroomWalkthrough.self, in: context)
            try expectSample(RubricComponent.self, in: context)
        }
        
        private func expectSample<T: PersistentModel>(_ modelType: T.Type, in context: ModelContext) throws {
            let result = try context.fetch(FetchDescriptor<T>())
            #expect(!result.isEmpty, "Should have at least one sample for \(T.self)")
        }
    }
    
}
