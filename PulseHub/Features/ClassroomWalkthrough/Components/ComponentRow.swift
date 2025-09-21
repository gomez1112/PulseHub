//
//  ComponentRow.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/13/25.
//


import SwiftUI

struct ComponentRow: View {
    let component: RubricComponent
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(component.componentNumber)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(component.score.color)
                            }
                        
                        Text(component.domain.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(component.detail)
                        .font(.callout.weight(.medium))
                        .lineLimit(2)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack {
                RatingView(average: Double(component.score.numericValue))
                
                Spacer()
                
                if let comments = component.comments, !comments.isEmpty {
                    Text(comments)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBackground)
        }
    }
}

#Preview("Component Row") {
    ComponentRow(
        component: RubricComponent.samples[0],
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
