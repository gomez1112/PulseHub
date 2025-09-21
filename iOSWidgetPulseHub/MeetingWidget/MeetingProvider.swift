//
//  MeetingProvider.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import AppIntents
import WidgetKit
import SwiftData


@MainActor
struct MeetingProvider: AppIntentTimelineProvider {
    typealias Intent = ScheduleWidgetIntent
    typealias Entry = MeetingEntry
    
    func placeholder(in context: Context) -> MeetingEntry {
        MeetingEntry(date: Date(), meetings: Meeting.samples, showMeetingCount: true)
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> MeetingEntry {
        MeetingEntry(
            date: Date(),
            meetings: Meeting.samples,
            showMeetingCount: configuration.showMeetingCount ?? true
        )
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<MeetingEntry> {
        let meetings = await fetchMeetings()
        let entry = MeetingEntry(
            date: Date(),
            meetings: meetings.isEmpty ? Meeting.samples : meetings,
            showMeetingCount: configuration.showMeetingCount ?? true
        )

        // You can adjust the policy as needed; using .never keeps the static snapshot.
        return Timeline(entries: [entry], policy: .never)
    }
    
    private func fetchMeetings() async -> [Meeting] {
        do {
            let container = ModelContainerFactory.createSharedContainer
            let context = container.mainContext

            // Capture the current date outside of the predicate
            let now = Date()

            let descriptor = FetchDescriptor<Meeting>(
                predicate: #Predicate<Meeting> { meeting in
                    meeting.date > now
                },
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )
            
            let meetings = try context.fetch(descriptor)
            return Array(meetings.prefix(5))
        } catch {
            // Fallback to samples on error
            return Meeting.samples
        }
    }
}

