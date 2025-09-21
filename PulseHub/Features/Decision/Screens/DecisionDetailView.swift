import SwiftUI

struct DecisionDetailView: View {
    @Environment(DataModel.self) private var model
    @Environment(NavigationContext.self) private var navigation
    @Environment(\.dismiss) private var dismiss
    
    let decision: Decision

    @State private var showDeleteAlert = false
    @State private var effectivenessRating: Bool?
    @State private var isRatingChanging = false
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with Animation
                headerSection
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                
                // Quick Stats
                quickStatsSection
                
                // Impact Analysis
                impactAnalysisSection
                
                // Details
                if let detail = decision.detail {
                    expandableSection(
                        id: "details",
                        title: "Details",
                        icon: "doc.text",
                        color: .blue,
                        content: detail
                    )
                }
                
                // Rationale
                expandableSection(
                    id: "rationale",
                    title: "Rationale",
                    icon: "brain",
                    color: .purple,
                    content: decision.rationale,
                )
                .disabled(decision.rationale.isEmpty)
                
                // Next Steps
                if let nextSteps = decision.nextSteps {
                    nextStepsSection(nextSteps)
                }
                
                // Effectiveness Review
                effectivenessSection
                
                // Reflection
                if let reflection = decision.reflection {
                    reflectionSection(reflection)
                }
                
                // Related Meeting
                if let meeting = decision.meeting {
                    relatedMeetingSection(meeting)
                }
                
                // Timeline
                timelineSection
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .background(Color.cardBackground)
        .navigationTitle("Decision Details")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem {
                if decision.reflection == nil {
                    Button {
                        navigation.presentSheet(.reflection(decision))
                    } label: {
                        Label("Add Reflection", systemImage: "quote.bubble")
                    }
                }
            }
            ToolbarSpacer(.fixed)
            ToolbarItemGroup {
                    Button {
                        navigation.presentSheet(.editDecision(decision))
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
            }
        }
        .alert("Delete Decision", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                model.delete(decision)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this decision? This action cannot be undone.")
        }
        .onAppear {
            effectivenessRating = decision.wasEffective
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    // Tags
                    HStack(spacing: 8) {
                        // Impact Level
                        HStack(spacing: 6) {
                            Image(systemName: decision.impact.icon)
                                .font(.caption.weight(.medium))
                            Text(decision.impact.rawValue)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(decision.impact.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(decision.impact.color.opacity(0.15))
                        }
                        .overlay {
                            Capsule()
                                .strokeBorder(decision.impact.color.opacity(0.3), lineWidth: 1)
                        }
                        
                        // Effectiveness Status
                        if let effective = decision.wasEffective {
                            HStack(spacing: 4) {
                                Image(systemName: effective ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.caption)
                                Text(effective ? "Effective" : "Ineffective")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(effective ? .green : .orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(effective ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                            }
                            .overlay {
                                Capsule()
                                    .strokeBorder(effective ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                            }
                            .scaleEffect(isRatingChanging ? 1.1 : 1.0)
                        }
                    }
                    
                    // Title
                    Text(decision.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.2)
                    
                    // Date
                    HStack(spacing: 16) {
                        Label(decision.dateMade.formatted(.dateTime.weekday(.wide).month().day().year()), systemImage: "calendar")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        if let meeting = decision.meeting {
                            Label(meeting.title, systemImage: "person.3")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Impact Visual
                ZStack {
                    Circle()
                        .fill(decision.impact.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 4) {
                        Image(systemName: decision.impact.icon)
                            .font(.title2.weight(.medium))
                            .foregroundStyle(decision.impact.color.gradient)
                            .symbolEffect(.bounce, value: decision.impact)
                        
                        Text("Impact")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 16) {
            QuickStat(
                icon: decision.impact.icon, value: decision.impact.rawValue,
                label: "Impact Level",
                color: decision.impact.color
            )
            
            if let effective = decision.wasEffective {
                QuickStat(
                    icon: effective ? "hand.thumbsup" : "hand.thumbsdown", value: effective ? "Yes" : "No",
                    label: "Effective",
                    color: effective ? .green : .orange
                )
            } else {
                QuickStat(
                    icon: "questionmark.circle", value: "TBD",
                    label: "Effectiveness",
                    color: .gray
                )
            }
            
            if decision.reflection != nil {
                QuickStat(
                    icon: "quote.bubble.fill", value: "Added",
                    label: "Reflection",
                    color: .indigo
                )
            }
            
            if decision.nextSteps != nil {
                QuickStat(
                    icon: "arrow.right.circle.fill", value: "Set",
                    label: "Next Steps",
                    color: .green
                )
            }
        }
    }
    
    private var impactAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Impact Analysis", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(decision.impact.color)
            
            VStack(spacing: 16) {
                // Impact Scale Visual
                HStack(spacing: 8) {
                    ForEach(ImpactLevel.allCases, id: \.self) { level in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(level == decision.impact ? level.color : Color.gray.opacity(0.3))
                                    .frame(width: level == decision.impact ? 20 : 12, height: level == decision.impact ? 20 : 12)
                                
                                if level == decision.impact {
                                    Circle()
                                        .stroke(level.color, lineWidth: 2)
                                        .frame(width: 28, height: 28)
                                }
                            }
                            
                            Text(level.rawValue)
                                .font(.caption2)
                                .foregroundStyle(level == decision.impact ? level.color : .secondary)
                                .fontWeight(level == decision.impact ? .semibold : .regular)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                
                Text("This decision has been categorized as having \(decision.impact.rawValue.lowercased()) impact on operations.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                // Impact Description
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(decision.impact.color)
                    
                    Text(decision.impact.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(decision.impact.color.opacity(0.1))
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func expandableSection(
        id: String,
        title: String,
        icon: String,
        color: Color,
        content: String,
        isExpanded: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    if expandedSections.contains(id) {
                        expandedSections.remove(id)
                    } else {
                        expandedSections.insert(id)
                    }
#if !os(macOS)
                    AppTheme.selection()
                    #endif
                }
            } label: {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.headline)
                        .foregroundStyle(color)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(expandedSections.contains(id) || isExpanded ? 0 : -90))
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            if expandedSections.contains(id) || (isExpanded && !expandedSections.contains(id)) {
                Text(content)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .padding([.horizontal, .bottom])
                    .padding(.top, 4)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .cardStyle()
        .onAppear {
            if isExpanded {
                expandedSections.insert(id)
            }
        }
    }
    
    private func nextStepsSection(_ nextSteps: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Next Steps", systemImage: "arrow.right.circle")
                .font(.headline)
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(nextSteps)
                    .font(.callout)
                    .foregroundStyle(.primary)
                
                HStack {
                    Button {
                        // Create task from next steps
#if !os(macOS)
                        AppTheme.impact(.light)
                        #endif
                    } label: {
                        Label("Create Task", systemImage: "plus.circle")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.green)
                    
                    Button {
                        // Set reminder
#if !os(macOS)
                        AppTheme.impact(.light)
                        #endif
                    } label: {
                        Label("Set Reminder", systemImage: "bell")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .cardStyle()
    }
    
    private var effectivenessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Effectiveness Review", systemImage: "checkmark.seal")
                .font(.headline)
                .foregroundStyle(.indigo)
            
            VStack(alignment: .leading, spacing: 16) {
                if let rating = effectivenessRating {
                    HStack {
                        Text("Current Rating:")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            EffectivenessButton(
                                isEffective: true,
                                isSelected: rating,
                                size: .medium
                            ) {
                                updateEffectiveness(true)
                            }
                            
                            EffectivenessButton(
                                isEffective: false,
                                isSelected: !rating,
                                size: .medium
                            ) {
                                updateEffectiveness(false)
                            }
                        }
                    }
                    
                    Text("Last reviewed: \(Date().formatted())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("This decision hasn't been reviewed yet. Take a moment to evaluate its effectiveness.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 16) {
                        EffectivenessButton(
                            isEffective: true,
                            isSelected: false,
                            size: .large
                        ) {
                            updateEffectiveness(true)
                        }
                        
                        EffectivenessButton(
                            isEffective: false,
                            isSelected: false,
                            size: .large
                        ) {
                            updateEffectiveness(false)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func reflectionSection(_ reflection: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Reflection", systemImage: "quote.bubble")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                
                Spacer()
                
                Button {
                    navigation.presentSheet(.reflection(decision))
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.body)
                        .foregroundStyle(.indigo)
                }
            }
            
            Text(reflection)
                .font(.callout)
                .italic()
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.indigo.opacity(0.1))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(.indigo.opacity(0.2), lineWidth: 1)
                        }
                }
        }
        .padding()
        .cardStyle()
    }
    
    private func relatedMeetingSection(_ meeting: Meeting) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Related Meeting", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(.orange)
            
            NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meeting.title)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            Label(meeting.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            Label(meeting.type.rawValue, systemImage: "person.3")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.orange.opacity(0.1))
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .cardStyle()
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Timeline", systemImage: "timeline.selection")
                .font(.headline)
                .foregroundStyle(.teal)
            
            VStack(alignment: .leading, spacing: 16) {
                TimelineEvent(
                    date: decision.dateMade,
                    title: "Decision Made",
                    icon: "lightbulb",
                    color: .purple
                )
                
                if let meeting = decision.meeting {
                    TimelineEvent(
                        date: meeting.date,
                        title: "Discussed in \(meeting.title)",
                        icon: "calendar",
                        color: .orange
                    )
                }
                
                if let effective = decision.wasEffective {
                    TimelineEvent(
                        date: Date(), // This should be tracked properly
                        title: "Marked as \(effective ? "Effective" : "Ineffective")",
                        icon: effective ? "hand.thumbsup" : "hand.thumbsdown",
                        color: effective ? .green : .orange
                    )
                }
                
                if decision.reflection != nil {
                    TimelineEvent(
                        date: Date(), // This should be tracked properly
                        title: "Reflection Added",
                        icon: "quote.bubble",
                        color: .indigo
                    )
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if decision.reflection == nil {
                Button {
                    navigation.presentedSheet = .reflection(decision)
#if !os(macOS)
                    AppTheme.impact(.light)
                    #endif
                } label: {
                    Label("Add Reflection", systemImage: "quote.bubble.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack(spacing: 12) {
                ShareLink(item: "Decision: \(decision.title)\n\nRationale: \(decision.rationale)") {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    // Export as PDF
#if !os(macOS)
                    AppTheme.impact(.light)
                    #endif
                } label: {
                    Label("Export PDF", systemImage: "arrow.down.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private func updateEffectiveness(_ isEffective: Bool) {
        withAnimation(.spring(response: 0.3)) {
            decision.wasEffective = isEffective
            effectivenessRating = isEffective
            isRatingChanging = true
#if !os(macOS)
            AppTheme.impact(.medium)
            #endif
            
            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isRatingChanging = false
            }
        }
    }
}

#Preview(traits: .previewData) {
    NavigationStack {
        DecisionDetailView(decision: Decision.samples[0])
    }
}
