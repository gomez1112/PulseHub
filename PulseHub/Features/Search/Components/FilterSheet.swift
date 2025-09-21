//
//  FilterSheet.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/7/25.
//

import SwiftUI

struct FilterSheet: View {
    @Environment(DataModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFromDate = Date()
    @State private var tempToDate = Date()
    @State private var enableDateFilter = false
    
    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                Section("Sort Order") {
                    Picker("Sort by", selection: $model.sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Date Range") {
                    Toggle("Enable Date Filter", isOn: $enableDateFilter)
                    
                    if enableDateFilter {
                        DatePicker("From", selection: $tempFromDate, displayedComponents: .date)
                        DatePicker("To", selection: $tempToDate, displayedComponents: .date)
                    }
                }
                
                Section("Content Types") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Show content from:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            ForEach(SearchCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                                FilterToggleChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isEnabled: true // You can add state for this
                                ) {
                                    // Toggle category filter
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Reset All Filters") {
                        withAnimation {
                            model.sortOrder = .relevance
                            enableDateFilter = false
                            tempFromDate = Date()
                            tempToDate = Date()
#if !os(macOS)
                            AppTheme.impact(.light)
                            #endif
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Filters")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        model.isShowingFilters = false
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            model.isShowingFilters = true
        }
        .onDisappear {
            model.isShowingFilters = false
        }
    }
}

struct FilterToggleChip: View {
    let title: String
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isEnabled ? .white : .secondary)
            .padding(2)
            .background {
                Capsule()
                    .fill(isEnabled ? Color.accentColor : Color.chipBackground)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .previewData) {
    FilterSheet()
}
