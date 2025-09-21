//
//  AddComplianceView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftData
import SwiftUI

struct AddComplianceView: View {
    @Environment(DataModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var title = ""
    @State private var detail = ""
    @State private var dueDate = Date()
    @State private var priority = Priority.medium
    
    
    @Query private var categories: [ComplianceCategory]
    @FocusState private var titleFieldFocused: Bool
    
    // Helper to get unique categories
    private var uniqueCategories: [ComplianceCategory] {
        // Remove duplicates based on title
        var seen = Set<String>()
        return categories.filter { category in
            guard !seen.contains(category.title) else { return false }
            seen.insert(category.title)
            return true
        }
    }
    
    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                Section {
                    Label("Compliance Title", systemImage: "checkmark.shield")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    TextField("What is your compliance?", text: $title)
                        .font(.title3)
                        .focused($titleFieldFocused)
                }
                Label("Details(Optional)", systemImage: "doc.text")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                TextEditor(text: $detail)
                    .frame(minHeight: 80)
                    .padding(8)
                DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                Section {
                    HStack {
                        ForEach(Priority.allCases) { priority in
                            PriorityButton(priority: priority, isSelected: self.priority == priority) {
                                withAnimation(.spring(response: 0.3)) {
                                    self.priority = priority
                                    #if !os(macOS)
                                    AppTheme.selection()
                                    #endif
                                }
                            }
                        }
                    }
                } header: {
                    Label("Priority", systemImage: "exclamationmark.triangle.fill")
                }
                
                
                Section("Category") {
                    
                    Toggle("Create New Category", isOn: $model.isCreatingNewCategory.animation())
                    
                    if model.isCreatingNewCategory {
                        HStack {
                            TextField("Category Name", text: $model.newCategoryName)
                            Button("Add", action: createCategory) 
                                .disabled(model.newCategoryName.isEmpty)
                        }
                        if categoryExists(model.newCategoryName) && model.newCategoryName.isEmpty {
                            Text("Category already exisits")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        CategoryChip(title: "None", isSelected: model.selectedCategory == nil) {
                            model.selectedCategory = nil
                        }
                        ForEach(uniqueCategories) { category in
                            CategoryChip(title: category.title, isSelected: model.selectedCategory == category) {
                                model.selectedCategory = category
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    model.delete(category)
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle($title)
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                }
            }
        }
        .onAppear {
            titleFieldFocused = true
            model.selectedCategory = nil
        }
    }
    private func categoryExists(_ name: String) -> Bool {
        categories.contains { $0.title.lowercased() == name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    private func save() {
        model.saveItem(title: title, detail: detail, dueDate: dueDate, priority: priority)
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
    private func createCategory() {
        model.createCategory(existingCategories: categories)
#if !os(macOS)
        AppTheme.impact(.light)
        #endif
    }
}

#Preview(traits: .previewData) {
    AddComplianceView()
}
