//
//  ComplianceProvider.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import WidgetKit
import AppIntents
import SwiftData


@MainActor
struct ComplianceProvider: AppIntentTimelineProvider {
    typealias Intent = ComplianceWidgetIntent
    typealias Entry = ComplianceEntry

    func placeholder(in context: Context) -> ComplianceEntry {
        ComplianceEntry(date: Date(), items: ComplianceItem.samples)
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> ComplianceEntry {
        ComplianceEntry(date: Date(), items: ComplianceItem.samples)
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<ComplianceEntry> {
        let items = await fetchComplianceItems()
        let entry = ComplianceEntry(date: Date(), items: items)

        return Timeline(entries: [entry], policy: .never)
    }

    private func fetchComplianceItems() async -> [ComplianceItem] {
        do {
            let container = ModelContainerFactory.createSharedContainer
            let context = container.mainContext
            let descriptor = FetchDescriptor<ComplianceItem>(
                sortBy: [SortDescriptor(\.dueDate, order: .forward)]
            )
            
            return try context.fetch(descriptor)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}
