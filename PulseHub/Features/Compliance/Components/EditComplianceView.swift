//
//  EditComplianceView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct EditComplianceView: View {
    @Bindable var item: ComplianceItem
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: Priority = .medium
    @State private var status: ComplianceStatus = .pending
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Compliance Title", systemImage: "checkmark.shield")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    TextField("What is your compliance?", text: $title)
                        .font(.title3)
                }
                Label("Details(Optional)", systemImage: "doc.text")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                TextEditor(text: $detail)
                    .frame(minHeight: 80)
                    .padding(8)
                DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                
                Section("Settings") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Label(priority.rawValue, systemImage: priority.icon)
                                .tag(priority)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(ComplianceStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationTitle(item.title)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: saveChanges)
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            title = item.title
            detail = item.detail ?? ""
            dueDate = item.dueDate
            priority = item.priority
            status = item.status
        }
    }
    
    private func saveChanges() {
        item.title = title
        item.detail = detail.isEmpty ? nil : detail
        item.dueDate = dueDate
        item.priority = priority
        item.status = status
        dismiss()
    }
}


#Preview {
    NavigationStack {
        EditComplianceView(item: ComplianceItem(title: "Sample Compliance", category: ComplianceCategory.samples[0], dueDate: Date()))
    }
}
