//
//  CategoryPill.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI

struct CategoryPill: View {
    let category: SearchCategory
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> ()
    
    @State private var isPressed = false
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.caption.weight(.semibold))
                    .symbolEffect(.bounce, value: isSelected)
                Text(category.rawValue)
                    .font(.callout.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding()
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.accentColor.gradient)
                        .matchedGeometryEffect(id: "selected", in: namespace)
                } else {
                    Capsule()
                        .fill(.quaternary)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {}
        onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }
    }
}




#Preview {
    CategoryPill(
        category: SearchCategory.all,
        isSelected: true,
        namespace: Namespace().wrappedValue,
        action: {}
    )
}
