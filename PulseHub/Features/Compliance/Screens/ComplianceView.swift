//
//  ComplianceView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI
import SwiftData

struct ComplianceView: View {
    @Environment(NavigationContext.self) private var navigation
    @Environment(DataModel.self) private var model
    
    private static let complianceRawValue = TaskType.compliance.rawValue
    
    @Query(
        filter: #Predicate<ProjectTask> { task in
            task.taskType.rawValue == complianceRawValue
        },
        sort: \.dueDate,
        order: .forward
    ) private var items: [ProjectTask]
    
    @Namespace private var animation
    
    
    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(spacing: 20) {
                if model.isShowingStats {
                    statsOverview
                        .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                }
                filterSection
                ForEach(model.groupedItems(items: items), id: \.0) { section, sectionItems in
                    ComplianceSection(title: section, items: sectionItems, animation: animation) { item in
                        navigation.navigate(to: .task(item))
                    }
                }
                if model.filtered(items: items).isEmpty {
                    emptyState
                }
            }
            .padding(.vertical)
        }
        .background(Color.cardBackground)
        .navigationTitle("Compliance")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .searchable(text: $model.searchText, prompt: "Search Compliance items")
    }
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Status",
                    isSelected: model.filterStatus == nil,
                    count: items.count
                ) {
                    withAnimation { model.filterStatus = nil }
                }
                
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 4)
                
                FilterChip(
                    title: "All Priority",
                    isSelected: model.filterPriority == nil,
                    count: items.count
                ) {
                    withAnimation { model.filterPriority = nil }
                }
                
                ForEach(Priority.allCases, id: \.self) { priority in
                    let count = items.filter { $0.priority == priority }.count
                    FilterChip(
                        title: priority.rawValue,
                        isSelected: model.filterPriority == priority,
                        count: count,
                        color: priority.color
                    ) {
                        withAnimation {
                            model.filterPriority = priority
#if !os(macOS)
                            AppTheme.selection()
                            #endif
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    private var statsOverview: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ComplianceStatPill(
                value: model.stats(items: items).pending,
                label: "Pending",
                color: .gray
            )
            
            ComplianceStatPill(
                value: model.stats(items: items).inProgress,
                label: "In Progress",
                color: .blue
            )
            
            ComplianceStatPill(
                value: model.stats(items: items).completed,
                label: "Completed",
                color: .green
            )
            
            ComplianceStatPill(
                value: model.stats(items: items).overdue,
                label: "Overdue",
                color: .red
            )
        }
        .padding(.horizontal)
    }
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: model.filterStatus != nil || model.filterPriority != nil ? "magnifyingglass" : "checkmark.shield")
                .font(.system(size: 48))
                .foregroundStyle(.quaternary)
                .symbolEffect(.pulse)
            
            Text(model.filterStatus != nil || model.filterPriority != nil ? "No Matching Items" : "All Caught Up!")
                .font(.title3.bold())
            
            Text(model.filterStatus != nil || model.filterPriority != nil ? "Try adjusting your filters" : "No compliance items to show")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            if model.filterStatus != nil || model.filterPriority != nil {
                Button("Clear Filters") {
                    withAnimation {
                        model.filterStatus = nil
                        model.filterPriority = nil
#if !os(macOS)
                        AppTheme.impact(.light)
                        #endif
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview(traits: .previewData) {
    NavigationStack {
        ComplianceView()
    }
}
