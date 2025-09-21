//
//  DecisionWidgetView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct DecisionWidgetView: View {
    let entry: DecisionEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallDecisionView(entry: entry)
        case .systemMedium:
            MediumDecisionView(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct SmallDecisionView: View {
    let entry: DecisionEntry
    
    private var effectivenessPercentage: Int {
        Int(entry.stats.effectivenessRate * 100)
    }
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.purple.opacity(0.15), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                    Spacer()
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: entry.stats.effectivenessRate)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(effectivenessPercentage)%")
                            .font(.title2.bold())
                        Text("Effective")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(entry.stats.pending)")
                            .font(.callout.bold())
                            .foregroundStyle(.purple)
                        Text("Pending")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    VStack(spacing: 2) {
                        Text("\(entry.stats.effective)")
                            .font(.callout.bold())
                            .foregroundStyle(.green)
                        Text("Effective")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .containerBackground(backgroundGradient, for: .widget)
    }
}

struct MediumDecisionView: View {
    let entry: DecisionEntry
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.purple.opacity(0.08), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title)
                            .foregroundStyle(.purple)
                        Text("Decisions")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(index < 3 ? Color.green : Color.purple.opacity(0.3))
                                .frame(width: 8, height: CGFloat.random(in: 20...40))
                        }
                    }
                    
                    HStack(spacing: 20) {
                        MetricPill(value: entry.stats.effective, label: "Effective", color: .green)
                        MetricPill(value: entry.stats.pending, label: "Pending", color: .purple)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(height: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Needs Review")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.purple)
                    
                    if let recentDecision = entry.stats.recentDecisions.first {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recentDecision.title)
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text(recentDecision.impact)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(intent: ReviewDecisionIntent(decision: recentDecision, wasEffective: true)) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.green))
                            }
                            .buttonStyle(.plain)
                            
                            Button(intent: ReviewDecisionIntent(decision: recentDecision, wasEffective: false)) {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.orange))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .containerBackground(backgroundGradient, for: .widget)
    }
}

struct MetricPill: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.callout.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
