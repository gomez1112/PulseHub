//
//  TodayView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/18/25.
//

import SwiftUI
import SwiftData
import Charts

struct TodayView: View {
    @Environment(NavigationContext.self) private var navigation
    @Environment(DataModel.self) private var model
    
    @Query(sort: \ProjectTask.dueDate, order: .forward) private var items: [ProjectTask]
    @Query private var decisions: [Decision]
    @Query private var meetings: [Meeting]
    @Query private var observations: [ClassroomWalkthrough]
    
    @State private var currentTime = Date()
    @State private var selectedTimeFilter: TimeFilter = .today
    @State private var animateCards = false
    @State private var pulseAnimation = false
    @State private var pulseTask: Task<Void, Never>? = nil
    
    // Today's data
    private var todaysMeetings: [Meeting] {
        meetings.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    private var tomorrowsMeetings: [Meeting] {
        meetings.filter { Calendar.current.isDateInTomorrow($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    private var todaysOverdueItems: [ProjectTask] {
        items.filter { $0.isOverdue }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    private var todaysDueItems: [ProjectTask] {
        items.filter { Calendar.current.isDateInToday($0.dueDate) && !$0.isOverdue }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    private var pendingDecisions: [Decision] {
        decisions.filter { $0.wasEffective == nil }
            .sorted { $0.dateMade > $1.dateMade }
            .prefix(3)
            .map { $0 }
    }
    
    private var todaysObservations: [ClassroomWalkthrough] {
        observations.filter {
            Calendar.current.isDateInToday($0.date) ||
            // MODIFIED: Safely unwrap the followUpDate.
            ($0.followUpRequired && $0.followUpDate.map(Calendar.current.isDateInToday) == true)
        }
    }
    
    private var hasItemsToday: Bool {
        !todaysMeetings.isEmpty || !todaysOverdueItems.isEmpty ||
        !todaysDueItems.isEmpty || !pendingDecisions.isEmpty || !todaysObservations.isEmpty
    }
    
    private var totalTasksToday: Int {
        todaysOverdueItems.count + todaysDueItems.count + todaysMeetings.count
    }
    
    private var completedToday: Int {
        items.filter { item in
            guard let completedDate = item.completedDate else { return false }
            return Calendar.current.isDateInToday(completedDate)
        }.count
    }
    
    enum TimeFilter: String, CaseIterable {
        case today = "Today"
        case tomorrow = "Tomorrow"
        case thisWeek = "This Week"
        
        var icon: String {
            switch self {
                case .today: return "sun.max.fill"
                case .tomorrow: return "sun.haze.fill"
                case .thisWeek: return "calendar.circle.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Dynamic Header
                dynamicHeader
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Progress Overview
                if hasItemsToday {
                    progressOverview
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                
                // Main Content
                if hasItemsToday {
                    VStack(spacing: 20) {
                        // Priority Matrix
                        if !todaysOverdueItems.isEmpty || !todaysDueItems.isEmpty {
                            priorityMatrix
                        }
                        
                        // Timeline View
                        if !todaysMeetings.isEmpty {
                            timelineView
                        }
                        
                        // Pending Reviews with Visual Appeal
                        if !pendingDecisions.isEmpty {
                            pendingReviewsSection
                        }
                        
                        // Observations Grid
                        if !todaysObservations.isEmpty {
                            observationsGrid
                        }
                        
                        // Tomorrow Preview
                        if !tomorrowsMeetings.isEmpty {
                            tomorrowPreview
                        }
                    }
                    .padding(.horizontal)
                } else {
                    emptyStateView
                }
                
                // Footer Insights
                footerInsights
                    .padding(.horizontal)
                    .padding(.top, 30)
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.systemBackgroundCompat,
                    Color.secondarySystemBackgroundCompat.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Command Center")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(["Meeting", "Compliance", "Decision", "Observation"], id: \.self) { type in
                        Button {
                            handleQuickAdd(type: type)
                        } label: {
                            Label("New \(type)", systemImage: iconForType(type))
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .refreshable {
            currentTime = Date()
            animateCards = true
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateCards = true
            }
            startPulseTask()
        }
        .onDisappear {
            pulseTask?.cancel()
            pulseTask = nil
        }
    }
    
    private var dynamicHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting with Time
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.greeting)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(currentTime.formatted(.dateTime.weekday(.wide).month().day()))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .foregroundStyle(.tertiary)
                        
                        Text(currentTime.formatted(date: .omitted, time: .shortened))
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                
                Spacer()
                
                // Weather or Status Widget
                WeatherWidget()
            }
            
            // Smart Summary
            if hasItemsToday {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .symbolEffect(.pulse, value: pulseAnimation)
                    
                    Text("You have \(totalTasksToday) items today, \(todaysOverdueItems.count) need immediate attention")
                        .font(.callout)
                        .foregroundStyle(.primary)
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.orange.opacity(0.1))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                }
            }
        }
    }
    
    private var progressOverview: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(completedToday) of \(totalTasksToday)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: totalTasksToday > 0 ? geometry.size.width * (Double(completedToday) / Double(totalTasksToday)) : 0)
                        .animation(.spring(response: 0.5), value: completedToday)
                }
                .frame(height: 12)
            }
            .frame(height: 12)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }

    private var priorityMatrix: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Priority Focus",
                icon: "flag.fill",
                color: .red,
                count: todaysOverdueItems.count + todaysDueItems.count
            )
            
            // Overdue Items
            if !todaysOverdueItems.isEmpty {
                VStack(spacing: 12) {
                    ForEach(todaysOverdueItems.prefix(3)) { item in
                        EnhancedTaskCard(
                            item: item,
                            style: .critical
                        ) {
                            navigation.navigate(to: .task(item))
                        }
                        .transition(.asymmetric(
                            insertion: .push(from: .trailing).combined(with: .opacity),
                            removal: .push(from: .leading).combined(with: .opacity)
                        ))
                    }
                    
                    if todaysOverdueItems.count > 3 {
                        ExpandButton(count: todaysOverdueItems.count - 3, color: .red) {
                            navigation.navigate(to: .compliance)
                        }
                    }
                }
            }
            
            // Due Today
            if !todaysDueItems.isEmpty {
                VStack(spacing: 12) {
                    ForEach(todaysDueItems) { item in
                        EnhancedTaskCard(
                            item: item,
                            style: .normal
                        ) {
                            navigation.navigate(to: .task(item))
                        }
                        .transition(.asymmetric(
                            insertion: .push(from: .trailing).combined(with: .opacity),
                            removal: .push(from: .leading).combined(with: .opacity)
                        ))
                    }
                }
            }
        }
    }
    
    private var timelineView: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Today's Timeline",
                icon: "calendar.day.timeline.left",
                color: .orange,
                count: todaysMeetings.count
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(todaysMeetings) { meeting in
                        TimelineCard(meeting: meeting) {
                            navigation.navigate(to: .meeting(meeting))
                        }
                    }
                }
            }
        }
    }
    
    private var pendingReviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Pending Reviews",
                icon: "questionmark.circle.fill",
                color: .purple,
                badge: "Action Required"
            )
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(pendingDecisions) { decision in
                    ReviewCard(decision: decision) {
                        navigation.navigate(to: .decision(decision))
                    }
                }
            }
        }
    }
    
    private var observationsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Observations",
                icon: "eye.fill",
                color: .green,
                count: todaysObservations.count
            )
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(todaysObservations.prefix(4)) { observation in
                    ObservationGridCard(observation: observation) {
                        navigation.navigate(to: .observation(observation))
                    }
                }
            }
        }
    }
    
    private var tomorrowPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Tomorrow's Preview", systemImage: "sun.haze.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("\(tomorrowsMeetings.count) meetings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tomorrowsMeetings) { meeting in
                        MiniMeetingCard(meeting: meeting)
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.05), .blue.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var footerInsights: some View {
        HStack(spacing: 16) {
            InsightCard(
                title: "Productivity",
                value: "\(Int(Double(completedToday) / max(Double(totalTasksToday), 1) * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            
            InsightCard(
                title: "Focus Time",
                value: "\(todaysMeetings.count * 45) min",
                icon: "timer",
                color: .orange
            )
            
            InsightCard(
                title: "Reviews",
                value: "\(pendingDecisions.count)",
                icon: "checkmark.seal",
                color: .purple
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 60)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse)
            }
            
            VStack(spacing: 12) {
                Text("All Clear!")
                    .font(.title.bold())
                
                Text("No pressing items for today.\nTime to plan ahead or take a break.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                navigation.presentSheet(.addMeeting)
            } label: {
                Label("Schedule Something", systemImage: "plus.circle.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.accentColor, .accentColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func startPulseTask() {
        // Cancel any existing task before starting a new one
        pulseTask?.cancel()
        pulseTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                await MainActor.run {
                    pulseAnimation.toggle()
                }
            }
        }
    }
    
    private func handleQuickAdd(type: String) {
        switch type {
            case "Meeting":
                navigation.presentSheet(.addMeeting)
            case "Compliance":
                navigation.presentSheet(.addTask)
            case "Decision":
                navigation.presentSheet(.addDecision)
            case "Observation":
                navigation.presentSheet(.addObservation)
            default:
                break
        }
#if !os(macOS)
        AppTheme.impact(.light)
#endif
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
            case "Meeting": return "calendar.badge.plus"
            case "Compliance": return "checkmark.shield"
            case "Decision": return "lightbulb"
            case "Observation": return "eye"
            default: return "plus"
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    var count: Int? = nil
    var badge: String? = nil
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(.headline)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(color)
                    }
            } else if let count = count {
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(color.opacity(0.15))
                    }
            }
        }
    }
}

struct EnhancedTaskCard: View {
    let item: ProjectTask
    let style: CardStyle
    let action: () -> Void
    
    enum CardStyle {
        case critical, normal
        
        var gradient: LinearGradient {
            switch self {
                case .critical:
                    return LinearGradient(
                        colors: [.red, .red.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .normal:
                    return LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            }
        }
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
#if !os(macOS)
            AppTheme.selection()
#endif
            action()
        }) {
            HStack {
                // Priority Indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(style.gradient)
                    .frame(width: 4)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Visual Priority Indicator
                        ZStack {
                            Circle()
                                .fill(item.priority.color.opacity(0.15))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: item.priority.icon)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(item.priority.color)
                        }
                    }
                    
                    HStack {
                        Label {
                            Text(style == .critical ? "Overdue by \(abs(item.daysToDue)) days" : "Due by end of day")
                                .font(.caption2.weight(.medium))
                        } icon: {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.caption2)
                        }
                        .foregroundStyle(style == .critical ? .red : .orange)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                style == .critical ? Color.red.opacity(0.2) : Color.clear,
                                lineWidth: 1
                            )
                    }
            }
            .shadow(
                color: style == .critical ? .red.opacity(0.1) : .black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }
    }
}

struct TimelineCard: View {
    let meeting: Meeting
    let action: () -> Void
    
    @State private var isHovered = false
    
    private var timeUntilMeeting: (String, Color) {
        let now = Date()
        let interval = meeting.date.timeIntervalSince(now)
        
        if interval < 0 {
            return (meeting.status == .inProgress ? "In Progress" : "Past", .gray)
        } else if interval < 900 { // 15 minutes
            return ("Starting Soon", .red)
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return ("In \(minutes) min", .orange)
        } else {
            let hours = Int(interval / 3600)
            return ("In \(hours) hr", .blue)
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Time Badge
                HStack {
                    Text(meeting.startTime, format: .dateTime.hour().minute())
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                    
                    Spacer()
                    
                    Text(timeUntilMeeting.0)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(timeUntilMeeting.1)
                        }
                }
                
                // Meeting Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(meeting.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(meeting.type.rawValue, systemImage: meeting.type.icon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if !meeting.attendees.isEmpty {
                            Label("\(meeting.attendees.count)", systemImage: "person.2")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Duration Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.6), .orange.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * 0.6)
                    }
                    .frame(height: 4)
                }
                .frame(height: 4)
                
                Text(meeting.formatterDuration)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .frame(width: 200)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                meeting.status == .inProgress ? Color.green.opacity(0.3) : Color.clear,
                                lineWidth: 2
                            )
                    }
            }
            .shadow(
                color: .black.opacity(isHovered ? 0.1 : 0.05),
                radius: isHovered ? 12 : 8,
                x: 0,
                y: isHovered ? 6 : 4
            )
            .scaleEffect(isHovered ? 1.02 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
            }
        }
    }
}

struct ReviewCard: View {
    let decision: Decision
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(decision.title)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Image(systemName: decision.impact.icon)
                            .font(.caption)
                            .foregroundStyle(decision.impact.color)
                            .padding(6)
                            .background {
                                Circle()
                                    .fill(decision.impact.color.opacity(0.15))
                            }
                    }
                    
                    Text("Made \(decision.dateMade.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label("Needs Review", systemImage: "questionmark.circle")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.purple)
                        
                        Spacer()
                        
                        Button {
                            // Quick review action
                        } label: {
                            Text("Quick Review")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    Capsule()
                                        .fill(.purple)
                                }
                        }
                    }
                }
                .padding()
            }
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.05), .purple.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(.purple.opacity(0.2), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ObservationGridCard: View {
    let observation: ClassroomWalkthrough
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    
                    Spacer()
                    
                    if observation.followUpRequired {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Text(observation.teacherName)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(observation.subject)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack {
                    RatingView(average: Double(observation.overallRating.numericValue))
                        .scaleEffect(0.8)
                    
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                observation.followUpRequired ? Color.orange.opacity(0.2) : Color.clear,
                                lineWidth: 1
                            )
                    }
            }
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MiniMeetingCard: View {
    let meeting: Meeting
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(meeting.startTime, format: .dateTime.hour().minute())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.blue)
            
            Text(meeting.title)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Label("\(meeting.attendees.count)", systemImage: "person.2")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 120)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBackground)
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBackground)
        }
    }
}

struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sun.max.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("72°")
                    .font(.title3.bold())
                Text("Sunny")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.yellow.opacity(0.1))
        }
    }
}

struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(action.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: action.icon)
                        .font(.body.weight(.medium))
                        .foregroundStyle(action.color)
                }
                
                Text(action.title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .frame(width: 64)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExpandButton: View {
    let count: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("View \(count) more")
                    .font(.caption.weight(.medium))
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.caption)
            }
            .foregroundStyle(color)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.1))
            }
        }
    }
}

enum QuickAction: String, CaseIterable {
    case focus = "Focus"
    case review = "Review"
    case report = "Report"
    case insights = "Insights"
    
    var icon: String {
        switch self {
            case .focus: return "scope"
            case .review: return "checkmark.seal"
            case .report: return "doc.text"
            case .insights: return "chart.xyaxis.line"
        }
    }
    
    var color: Color {
        switch self {
            case .focus: return .orange
            case .review: return .purple
            case .report: return .blue
            case .insights: return .green
        }
    }
    
    var title: String {
        rawValue
    }
}

#Preview(traits: .previewData) {
    TodayView()
}

