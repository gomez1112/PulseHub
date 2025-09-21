//
//  QuickAddIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct QuickAddIntent: AppIntent {
    static let title: LocalizedStringResource = "Quick Add"
    static let description = IntentDescription("Quickly add a new item")
    
    enum ItemType: String, AppEnum {
        case meeting
        case compliance
        case decision
        
        static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Item Type")
        
        static let caseDisplayRepresentations: [ItemType: DisplayRepresentation] = [
            .meeting: "Meeting",
            .compliance: "Compliance",
            .decision: "Decision"
        ]
    }
    
    @Parameter(title: "Type")
    var itemType: ItemType

    init() {}

    init(itemType: ItemType) {
        self.itemType = itemType
    }
    
    func perform() async throws -> some IntentResult {
        // Open app with add sheet
        return .result()
    }
}

