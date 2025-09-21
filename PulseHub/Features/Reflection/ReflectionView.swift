//
//  ReflectionView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftData
import SwiftUI

struct ReflectionView: View {
    let decision: Decision
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var reflection = ""
    @State private var wasEffective: Bool?
    
    @FocusState private var textFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Decision Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Reflecting on", systemImage: "quote.bubble")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(decision.title)
                            .font(.title2.bold())
                        
                        if let detail = decision.detail {
                            Text(detail)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Label(decision.dateMade.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                            
                            Label(decision.impact.rawValue, systemImage: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundStyle(decision.impact.color)
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Effectiveness Rating
                    VStack(alignment: .leading, spacing: 16) {
                        Label("How effective was this decision?", systemImage: "checkmark.seal")
                            .font(.headline)
                        
                        HStack(spacing: 24) {
                            EffectivenessButton(
                                isEffective: true,
                                isSelected: wasEffective == true
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    wasEffective = true
#if !os(macOS)
                                    AppTheme.impact(.light)
                                    #endif
                                }
                            }
                            
                            EffectivenessButton(
                                isEffective: false,
                                isSelected: wasEffective == false
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    wasEffective = false
#if !os(macOS)
                                    AppTheme.impact(.light)
                                    #endif
                                }
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Reflection Text
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Your Reflection", systemImage: "text.alignleft")
                            .font(.headline)
                        
                        Text("What did you learn from this decision?")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $reflection)
                            .focused($textFieldFocused)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.quaternary)
                            }
                    }
                    .padding()
                    .cardStyle()
                }
                .padding()
            }
            .navigationTitle("Add Reflection")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: saveReflection)
                    .disabled(reflection.isEmpty || wasEffective == nil)
                }
            }
        }
        .onAppear {
            reflection = decision.reflection ?? ""
            wasEffective = decision.wasEffective
            textFieldFocused = true
        }
    }
    
    private func saveReflection() {
        decision.reflection = reflection
        decision.wasEffective = wasEffective
#if !os(macOS)
        AppTheme.impact(.medium)
        #endif
        dismiss()
    }
}


#Preview {
    NavigationStack {
        ReflectionView(
            decision: Decision(
                title: "Start Meditation Practice",
                detail: "Committed to meditating every morning before work.",
                dateMade: .now.addingTimeInterval(-86400 * 7),
                wasEffective: true, reflection: "I've found it helps my focus and mood. Worthwhile so far."
            )
        )
    }
}
