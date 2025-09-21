//
//  DecisionView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftData
import SwiftUI

struct DecisionView: View {
    @Environment(\.modelContext) private var context
    @Environment(NavigationContext.self) private var navigation
    @Environment(DataModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @Query(sort: \Decision.dateMade, order: .reverse) private var decisions: [Decision]

    @State private var selectedDecision: Decision?
    @State private var searchText = ""
    
    @Namespace private var animation
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Button {
                        try? context.delete(model: Decision.self)
                    } label: {
                        Text("Delete Decision")
                    }
                    Button {
                        try? context.delete(model: Meeting.self)
                    } label: {
                        Text("Delete Meeting")
                    }
                    Button {
                        try? context.delete(model: ComplianceItem.self)
                    } label: {
                        Text("Delete Compliance")
                    }
                    
                    // Analytics Toggle
                    if model.showAnalytics {
                        analyticsView
                            .transition(.asymmetric(
                                insertion: .push(from: .top),
                                removal: .push(from: .bottom)
                            ))
                    } else {
                        // Stats Overview
                        statsOverview
                    }
                    
                    // Filters
                    filterSection

                    // Decision Grid
                    if sizeClass == .regular {
                        decisionGrid
                    } else {
                        decisionList
                    }
                    
                    if model.filtered(searchText, decisions).isEmpty {
                        emptyState
                    }
                }
                .padding(.vertical)
            }
            .background(Color.cardBackground)
            .searchable(text: $searchText, prompt: "Search decisions")
    }
    // IMPORTANT: Create a computed property for filtered decisions
    private var filteredDecisions: [Decision] {
        model.filtered(searchText, decisions)
    }
    private var analyticsView: some View {
        VStack(spacing: 16) {
            // Effectiveness Chart
            HStack(spacing: 16) {
                EffectivenessChart(stats: model.effectivenessStats(filteredDecisions))
                    .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Effectiveness Rate")
                        .font(.headline)
                    
                    let total = model.effectivenessStats(filteredDecisions).effective + model.effectivenessStats(decisions).ineffective
                    let rate = total > 0 ? Double(model.effectivenessStats(filteredDecisions).effective) / Double(total) : 0
                    
                    Text("\(Int(rate * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(rate > 0.7 ? .green : .orange)
                    
                    Text("Based on \(total) reviewed decisions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .cardStyle()
            
            // Impact Distribution
            VStack(alignment: .leading, spacing: 12) {
                Text("Impact Distribution")
                    .font(.headline)
                
                ForEach(model.impactBreakdown(filteredDecisions), id: \.0) { level, count in
                    HStack {
                        Label(level.rawValue, systemImage: impactIcon(for: level))
                            .font(.callout)
                            .foregroundStyle(level.color)
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        GeometryReader { geometry in
                            Capsule()
                                .fill(level.color.opacity(0.2))
                                .overlay(alignment: .leading) {
                                    Capsule()
                                        .fill(level.color)
                                        .frame(width: decisions.count > 0 ? geometry.size.width * (Double(count) / Double(decisions.count)) : 0)
                                }
                        }
                        .frame(width: 100, height: 8)
                    }
                }
            }
            .padding()
            .cardStyle()
        }
        .padding(.horizontal)
    }
    
    private var statsOverview: some View {
        HStack(spacing: 12) {
            StatPill(
                value: model.effectivenessStats(filteredDecisions).effective,
                label: "Effective",
                color: .green,
                icon: "hand.thumbsup"
            )
            
            StatPill(
                value: model.effectivenessStats(filteredDecisions).ineffective,
                label: "Ineffective",
                color: .orange,
                icon: "hand.thumbsdown"
            )
            
            StatPill(
                value: model.effectivenessStats(filteredDecisions).pending,
                label: "Pending",
                color: .blue,
                icon: "clock"
            )
        }
        .padding(.horizontal)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: model.filterEffectiveness == nil && model.filterImpact == nil,
                    count: filteredDecisions.count
                ) {
                    withAnimation {
                        model.filterEffectiveness = nil
                        model.filterImpact = nil
                    }
                }
                
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 4)
                
                FilterChip(
                    title: "Effective",
                    isSelected: model.filterEffectiveness == true,
                    count: model.effectivenessStats(filteredDecisions).effective,
                    color: .green
                ) {
                    withAnimation {
                        model.filterEffectiveness = true
                        #if !os(macOS)
                        AppTheme.selection()
                        #endif
                    }
                }
                
                FilterChip(
                    title: "Ineffective",
                    isSelected: model.filterEffectiveness == false,
                    count: model.effectivenessStats(filteredDecisions).ineffective,
                    color: .orange
                ) {
                    withAnimation {
                        model.filterEffectiveness = false
                        #if !os(macOS)
                        AppTheme.selection()
                        #endif
                    }
                }
                
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 4)
                
                ForEach(ImpactLevel.allCases, id: \.self) { level in
                    let count = decisions.filter { $0.impact == level }.count
                    FilterChip(
                        title: level.rawValue,
                        isSelected: model.filterImpact == level,
                        count: count,
                        color: level.color
                    ) {
                        withAnimation {
                            model.filterImpact = level
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
    
    private var decisionGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 16) {
            ForEach(decisions) { decision in
                DecisionCard(decision: decision) {
                    navigation.navigate(to: .decision(decision))
                }
                .matchedGeometryEffect(id: decision.id, in: animation)
            }
        }
        .padding(.horizontal)
    }
    
    private var decisionList: some View {
        VStack(spacing: 8) {
            ForEach(decisions) { decision in
                DecisionCard(decision: decision) {
                    navigation.navigate(to: .decision(decision))
                }
                .matchedGeometryEffect(id: decision.id, in: animation)
                .transition(.asymmetric(
                    insertion: .push(from: .trailing),
                    removal: .push(from: .leading)
                ))
            }
        }
        .padding(.horizontal)
    }
    
    private func impactIcon(for level: ImpactLevel) -> String {
        switch level {
            case .low: return "arrow.down.circle"
            case .medium: return "minus.circle"
            case .high: return "arrow.up.circle"
            case .critical: return "exclamationmark.triangle"
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: model.filterEffectiveness != nil || model.filterImpact != nil ? "magnifyingglass" : "lightbulb")
                .font(.system(size: 48))
                .foregroundStyle(.quaternary)
                .symbolEffect(.pulse)
            
            Text(model.filterEffectiveness != nil || model.filterImpact != nil ? "No Matching Decisions" : "No Decisions Yet")
                .font(.title3.bold())
            
            Text(model.filterEffectiveness != nil || model.filterImpact != nil ? "Try adjusting your filters" : "Start tracking your decisions")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            if model.filterEffectiveness != nil || model.filterImpact != nil {
                Button("Clear Filters") {
                    withAnimation {
                        model.filterEffectiveness = nil
                        model.filterImpact = nil
                        #if !os(macOS)
                        AppTheme.impact(.light)
                        #endif
                    }
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    navigation.presentSheet(.addDecision)
                    #if !os(macOS)
                    AppTheme.impact(.light)
                    #endif
                } label: {
                    Label("New Decision", systemImage: "plus.circle")
                        .font(.callout.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview(traits: .previewData) {
    DecisionView()
}
