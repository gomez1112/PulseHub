//
//  Meeting+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/6/25.
//

import Foundation

extension DataModel {
    
    /// Filters the provided array of `Meeting` objects based on the current search text and filter type.
    ///
    /// - Parameter meetings: An array of `Meeting` objects to be filtered.
    /// - Returns: An array of `Meeting` objects that match the search text (in their title or any attendee's name)
    ///   and, if a filter type is set, only those meetings of that type.
    ///
    /// - Note: The search is case-insensitive for both the meeting title and attendees' names.
    func filtered(_ meetings: [Meeting]) -> [Meeting] {
        var result = meetings
        
        if !searchText.isEmpty {
            result = result.filter { meeting in
                meeting.title.localizedCaseInsensitiveContains(searchText) ||
                meeting.attendees.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        if let type = filterType {
            result = result.filter { $0.type == type }
        }
        
        return result
    }
    
    /// Groups the provided array of `Meeting` objects into time-based categories.
    ///
    /// - Parameter meetings: An array of `Meeting` objects to be grouped.
    /// - Returns: An array of tuples, each containing a group label (`String`) and a sorted array of `Meeting` objects
    ///   that belong to that group. The groups are ordered as: "Today", "Tomorrow", "This Week", "Upcoming", "Past".
    ///
    /// - Note:
    ///   - Each meeting is assigned to one of the following groups based on its date:
    ///     - "Today": The meeting occurs today.
    ///     - "Tomorrow": The meeting occurs tomorrow.
    ///     - "This Week": The meeting occurs within the current week (but not today or tomorrow).
    ///     - "Upcoming": The meeting occurs after this week and is in the future.
    ///     - "Past": The meeting occurred in the past.
    ///   - Only groups that contain at least one meeting are included in the result.
    ///   - Meetings within each group are sorted in ascending order by their date.
    ///   - The grouping leverages the `filtered(_:)` method to respect the current search and filter settings.
    func groupedMeetings(_ meetings: [Meeting]) -> [(String, [Meeting])] {
        let grouped = Dictionary(grouping: filtered(meetings)) { meeting in
            if Calendar.current.isDateInToday(meeting.date) {
                return "Today"
            } else if Calendar.current.isDateInTomorrow(meeting.date) {
                return "Tomorrow"
            } else if meeting.date.isThisWeek {
                return "This Week"
            } else if meeting.date > Date() {
                return "Upcoming"
            } else {
                return "Past"
            }
        }
        
        let order = ["Today", "Tomorrow", "This Week", "Upcoming", "Past"]
        return order.compactMap { key in
            guard let items = grouped[key] else { return nil }
            return (key, items.sorted { $0.date < $1.date })
        }
    }
}
