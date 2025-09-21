//
//  OpenComplianceItemIntent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents

struct OpenComplianceItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Compliance Item"
    static let description = IntentDescription("Opens a specific compliance item in PulseHub")
    static let openAppWhenRun: Bool = true
    
    @Parameter(title: "Item")
    var item: ComplianceItemEntity
    
    init() {}
    
    init(item: ComplianceItemEntity) {
        self.item = item
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
