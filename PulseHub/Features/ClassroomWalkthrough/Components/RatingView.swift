//
//  RatingView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import SwiftUI

struct RatingView: View {
    let average: Double
    
    private var category: (label: String, color: Color) {
        switch average {
            case 1..<2:
                return ("Ineffective", .red)
            case 2..<3:
                return ("Developing", .orange)
            case 3..<4:
                return ("Effective", .blue)
            case 4..<5:
                return ("Highly Effective", .green)
            default:
                return ("Ineffective", .red)
        }
    }
    
    var body: some View {
        Text(category.label)
            .font(.body.weight(.medium))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                category.color
                    .opacity(0.2)
                    .clipShape(Capsule())
            )
            .foregroundColor(category.color)
    }
}


#Preview {
    RatingView(average: 2.6)
}
#Preview {
    RatingView(average: 1.6)
}
#Preview {
    RatingView(average: 4.6)
}
#Preview {
    RatingView(average: 3.3)
}
