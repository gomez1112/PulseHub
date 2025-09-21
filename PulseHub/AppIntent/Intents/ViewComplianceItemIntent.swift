//
//  ViewComplianceItemIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct ViewComplianceItemIntent: AppIntent {
    static let title: LocalizedStringResource = "View Compliance Item"
    static let description = IntentDescription("Opens a specific compliance item in PulseHub")
    
    @Parameter(title: "Item")
    var item: ComplianceItemEntity
    
    func perform() async throws -> some IntentResult {
        // Deep link to the app
        return .result()
    }
}
