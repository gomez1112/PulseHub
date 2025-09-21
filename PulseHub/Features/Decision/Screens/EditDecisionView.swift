//
//  EditDecisionView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftData
import SwiftUI

struct EditDecisionView: View {
    let decision: Decision
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var rationale: String = ""
    @State private var impact: ImpactLevel = .medium
    @State private var nextSteps: String = ""
    @State private var wasEffective: Bool?
    @State private var reflection: String = ""
    
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
                    
                    Toggle("Effectiveness Reviewed", isOn: .constant(wasEffective != nil))
                        .disabled(true)
                    
                    if wasEffective != nil {
                        HStack {
                            Text("Rating")
                            Spacer()
                            if let effective = wasEffective {
                                Label(
                                    effective ? "Effective" : "Ineffective",
                                    systemImage: effective ? "hand.thumbsup" : "hand.thumbsdown"
                                )
                                .foregroundStyle(effective ? .green : .orange)
                            }
                        }
                    }
                }
                
                if !reflection.isEmpty {
                    Section("Reflection") {
                        TextEditor(text: $reflection)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Edit Decision")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: saveChanges)
                    .disabled(title.isEmpty || rationale.isEmpty)
                }
            }
        }
        .onAppear {
            title = decision.title
            detail = decision.detail ?? ""
            rationale = decision.rationale
            impact = decision.impact
            nextSteps = decision.nextSteps ?? ""
            wasEffective = decision.wasEffective
            reflection = decision.reflection ?? ""
        }
    }
    
    private func saveChanges() {
        decision.title = title
        decision.detail = detail.isEmpty ? nil : detail
        decision.rationale = rationale
        decision.impact = impact
        decision.nextSteps = nextSteps.isEmpty ? nil : nextSteps
        decision.reflection = reflection.isEmpty ? nil : reflection
#if !os(macOS)
        AppTheme.impact(.light)
        #endif
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
