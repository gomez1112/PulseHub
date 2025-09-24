//
//  EditDecisionView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftData
import SwiftUI

struct EditDecisionView: View {
    
    var decision: Decision?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var rationale: String = ""
    @State private var impact: ImpactLevel = .medium
    @State private var nextSteps: String = ""

    private var navigationTitle: String {
        decision == nil ? "New Decision" : "Edit Decision"
    }
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    TextField("Details", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Decision Context") {
                    TextField("Rationale", text: $rationale, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Impact Level", selection: $impact) {
                        ForEach(ImpactLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section("Follow Up") {
                    TextField("Next Steps", text: $nextSteps, axis: .vertical)
                        .lineLimit(2...4)
                }
                .navigationTitle(navigationTitle)
#if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel, action: dismiss.callAsFunction)
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm, action: save)
                            .disabled(!isFormValid)
                    }
                }
            }
            .onAppear(perform: setup)
        }
    }
    private func setup() {
        if let decision {
            // Editing an existing decision, so populate the form.
            title = decision.title
            detail = decision.detail ?? ""
            rationale = decision.rationale
            impact = decision.impact
            nextSteps = decision.nextSteps ?? ""
        }
    }
    private func save() {
        if let decision {
            // Update existing decision
            decision.title = title
            decision.detail = detail.isEmpty ? nil : detail
            decision.rationale = rationale
            decision.impact = impact
            decision.nextSteps = nextSteps.isEmpty ? nil : nextSteps
        } else {
            // Create and insert a new decision
            let newDecision = Decision(title: title, detail: detail.isEmpty ? nil : detail)
            newDecision.rationale = rationale
            newDecision.impact = impact
            newDecision.nextSteps = nextSteps.isEmpty ? nil : nextSteps
            modelContext.insert(newDecision)
        }
        dismiss()
    }
}


#Preview {
    NavigationStack {
        EditDecisionView(
            decision: .init(
                title: "Switch to Async/Await",
                detail: "Reviewed alternatives: Combine, GCD.",
                nextSteps: "Refactor networking layer.",
                wasEffective: true,
                reflection: "Transition went smoothly with minimal bugs."
            )
        )
    }
}
