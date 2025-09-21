//
//  EffectivenessChart.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import Charts
import SwiftUI


struct EffectivenessChart: View {
    let stats: (effective: Int, ineffective: Int, pending: Int)
    
    /// Total count for the center label.
    private var total: Int {
        stats.effective + stats.ineffective + stats.pending
    }
    
    /// Chart data derived from the raw stats.
    private var data: [CategoryStat] {
        guard total > 0 else { return [] }
        return [
            CategoryStat(category: "Effective",   value: Double(stats.effective),   color: .green),
            CategoryStat(category: "Ineffective", value: Double(stats.ineffective), color: .orange),
            CategoryStat(category: "Pending",     value: Double(stats.pending),     color: .blue)
        ]
    }
    
    var body: some View {
        ZStack {
            Chart(data) { slice in
                SectorMark(
                    angle: .value("Count", slice.value),
                    innerRadius: .ratio(0.6),     // Creates the donut hole
                    angularInset: 2               // Space between slices
                )
                .foregroundStyle(slice.color)
            }
            .chartLegend(.hidden)
            
            // Center overlay
            VStack(spacing: 4) {
                Text("\(total)")
                    .font(.title.bold())
                Text("Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct CategoryStat: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
    let color: Color
}

#Preview {
    EffectivenessChart(stats: (effective: 12, ineffective: 4, pending: 7))
}
