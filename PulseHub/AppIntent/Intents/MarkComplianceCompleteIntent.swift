//
//  MarkComplianceCompleteIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct MarkComplianceCompleteIntent: AppIntent {
    static let title: LocalizedStringResource = "Mark Complete"
    static let description = IntentDescription("Marks a compliance item as complete")
    static let openAppWhenRun: Bool = false
    
    @Dependency private var model: DataModel
    
    @Parameter(title: "Item")
    var item: ComplianceItemEntity
    
    init() {}
    
    init(item: ComplianceItemEntity) {
        self.item = item
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let items = try model.fetchItems(of: ComplianceItem.self)
        
        // Find the matching item by title (in production, use proper ID)
        if let matchingItem = items.first(where: { $0.id == item.id }) {
            matchingItem.status = .completed
            matchingItem.isResolved = true
            matchingItem.completedDate = Date()
            model.save(matchingItem)
            
            return .result(dialog: "Marked \(item.title) as complete")
        }
        
        return .result(dialog: "Could not find item")
    }
}
