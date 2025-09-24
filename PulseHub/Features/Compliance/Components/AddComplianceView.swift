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
    
    @FocusState private var titleFieldFocused: Bool

    
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

        }
    }
    private func save() {
        model.saveItem(title: title, detail: detail, dueDate: dueDate, priority: priority)
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
}

#Preview(traits: .previewData) {
    AddComplianceView()
}
