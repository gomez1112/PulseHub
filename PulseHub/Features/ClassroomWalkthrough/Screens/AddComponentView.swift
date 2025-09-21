//
//  AddComponentView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/13/25.
//

import SwiftUI

struct AddComponentView: View {
    let onSave: (RubricComponent) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var domain = DanielsonDomain.planningPreparation
    @State private var componentNumber = ""
    @State private var detail = ""
    @State private var score = DanielsonScore.developing
    @State private var comments = ""
    
    @FocusState private var componentNumberFocused: Bool
    
    var isValid: Bool {
        !componentNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Component Information") {
                    Picker("Domain", selection: $domain) {
                        ForEach(DanielsonDomain.allCases, id: \.self) { domain in
                            Text(domain.rawValue).tag(domain)
                        }
                    }
                    
                    TextField("Component Number (e.g., 1a, 3c)", text: $componentNumber)
                        .focused($componentNumberFocused)
                    
                    TextField("Component Description", text: $detail, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Rating") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(DanielsonScore.allCases, id: \.self) { rating in
                            RatingButtonView(
                                score: rating,
                                isSelected: score == rating
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    score = rating
#if !os(macOS)
                                    AppTheme.selection()
                                    #endif
                                }
                            }
                        }
                    }
                }
                
                Section("Comments (Optional)") {
                    TextEditor(text: $comments)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Component")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveComponent()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .onAppear {
            componentNumberFocused = true
        }
    }
    
    private func saveComponent() {
        let component = RubricComponent(
            domain: domain,
            componentNumber: componentNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            detail: detail.trimmingCharacters(in: .whitespacesAndNewlines),
            score: score,
            comments: comments.isEmpty ? nil : comments.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        onSave(component)
        dismiss()
    }
}

#Preview("Add Component") {
    AddComponentView { _ in }
}
