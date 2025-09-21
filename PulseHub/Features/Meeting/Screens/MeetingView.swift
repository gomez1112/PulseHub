//
//  MeetingView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftData
import SwiftUI

struct MeetingView: View {
    @Environment(\.modelContext) private var context
    @Environment(DataModel.self) private var model
    @Environment(NavigationContext.self) private var navigation
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Query(sort: \Meeting.date, order: .reverse) private var meetings: [Meeting]
    
    @State private var selectedMeeting: Meeting?
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    @Namespace private var animation
    
    var body: some View {
        Group {
            switch model.viewMode {
                case .list: listView
                case .calendar: calendarView
                case .timeline: timelineView
            }
        }
        .navigationTitle("Meetings")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    private var listView: some View {
        List {
            ForEach(model.groupedMeetings(meetings), id: \.0) { section, sectionMeetings in
                Section {
                    ForEach(sectionMeetings) { meeting in
                        MeetingCard(meeting: meeting) {
                            navigation.navigate(to: .meeting(meeting))
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { model.delete(meeting) }
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                } header: {
                    Text(section)
                        .font(.headline)
                        .foregroundStyle(section == "Today" ? .orange : .primary)
                } footer: { EmptyView()}
                
            }
            .listRowBackground(Color.clear)
            if model.filtered(meetings).isEmpty {
                ContentUnavailableView {
                    Label("No Meetings", systemImage: "calendar")
                } description: {
                    Text("Schedule your first meeting")
                } actions: {
                    Button {
                        navigation.presentSheet(.addMeeting)
                    } label: {
                        Text("New Meeting")
                    }
                }
                
            }
        }
        .listRowSeparator(.hidden)
        .scrollContentBackground(.hidden)
        .background(Color.cardBackground)
    }
    private var timelineView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(model.filtered(meetings).enumerated()), id: \.element.id) { index, meeting in
                    TimelineItem(
                        meeting: meeting,
                        isFirst: index == 0,
                        isLast: index == model.filtered(meetings).count - 1
                    ) {
                        selectedMeeting = meeting
                    }
                }
            }
            .padding()
        }
        .background(Color.cardBackground)
    }
    
    private var todaySchedule: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Today's Schedule", systemImage: "calendar.day.timeline.left")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(meetings.filter { Calendar.current.isDateInToday($0.date) }.sorted { $0.date < $1.date }) { meeting in
                        TodayMeetingCard(meeting: meeting) {  // ← TODAYMEETINGCARD USED HERE
                            selectedMeeting = meeting
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var calendarHeader: some View {
        HStack {
            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.title2.bold())
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            ForEach(calendarDays(), id: \.self) { date in
                CalendarDayView(  // ← CALENDARDAYVIEW USED HERE
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                    hasMeetings: meetings.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
                ) {
                    withAnimation {
                        selectedDate = date
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var selectedDateMeetings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meetings on \(selectedDate.formatted(.dateTime.weekday(.wide).month().day()))")
                .font(.headline)
            
            let dayMeetings = meetings.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            
            if dayMeetings.isEmpty {
                Text("No meetings scheduled")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(dayMeetings.sorted { $0.date < $1.date }) { meeting in
                    MeetingCard(meeting: meeting) {
                        selectedMeeting = meeting
                    }
                }
            }
        }
    }
    
    private func calendarDays() -> [Date] {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday
        let leadingEmptyDays = firstWeekday >= 0 ? firstWeekday : 7 + firstWeekday
        
        let days = (1..<monthRange.count + 1).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
        
        return Array(repeating: Date.distantPast, count: leadingEmptyDays) + days
    }
    
    private var calendarView: some View {
        VStack(spacing: 20) {
            // Calendar Header
            calendarHeader
            
            // Calendar Grid - USES CalendarDayView HERE
            calendarGrid
            
            // Selected Date Meetings
            selectedDateMeetings
        }
        .padding()
        .background(Color.cardBackground)
    }
}

#Preview(traits: .previewData) {
    MeetingView()
}
