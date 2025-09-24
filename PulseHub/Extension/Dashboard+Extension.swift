//
//  Dashboard+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/6/25.
//

import Foundation

extension DataModel {
    
    /// Returns a contextual greeting string based on the current hour of the day.
    /// - Returns: 
    ///     - "Good Morning" if the current time is between 12:00 AM and 11:59 AM.
    ///     - "Good Afternoon" if the current time is between 12:00 PM and 4:59 PM.
    ///     - "Good Evening" for any time after 5:00 PM.
    /// 
    /// Uses the device's current calendar and local time to determine the hour.
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
            case 0..<12: return "Good Morning"
            case 12..<17: return "Good Afternoon"
            default: return "Good Evening"
        }
    }
    
    /// Returns the top 5 upcoming compliance items that are unresolved and not past due.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to filter and sort.
    /// - Returns: An array containing up to 5 unresolved compliance items whose due dates have not yet passed, sorted in their original order.
    ///
    /// Items are considered "upcoming" if:
    ///   - `isResolved` is `false`
    ///   - `daysToDue` is greater than or equal to 0
    ///
    /// The result is limited to the first 5 items that meet these criteria.
    func upcomingItems(_ items: [ProjectTask]) -> [ProjectTask] {
        items.filter { !$0.isCompleted && $0.daysToDue >= 0 }.prefix(5).map { $0 }
    }
    
    /// Returns the number of overdue compliance items in the provided array.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to evaluate.
    /// - Returns: The count of items whose `isOverdue` property is `true`.
    ///
    /// An item is considered overdue if its `isOverdue` property evaluates to `true`.
    func overdueCount(_ items: [ProjectTask]) -> Int {
        items.filter { $0.isOverdue }.count
    }
    
    /// Calculates the completion rate for the given compliance items.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to evaluate.
    /// - Returns: A `Double` value representing the completion rate, where 1.0 is 100% completion and 0.0 is 0%.
    ///
    /// The completion rate is determined by dividing the number of items whose `status` is `.completed` by the total number of items.
    /// If there are no items in the input array, the function returns 0.
    func completionRate(_ items: [ProjectTask]) -> Double {
        let total = items.count
        guard total > 0 else { return 0 }
        let completed = items.filter { $0.status == .completed }.count
        return Double(completed) / Double(total)
    }
    /// Analyzes the trend in the number of meetings for the currently selected time range compared to the previous equivalent period.
    ///
    /// - Parameter meetings: An array of `Meeting` objects to analyze.
    /// - Returns: A `Trend` value representing the change in the number of meetings:
    ///     - `.up(n)` if there are `n` more meetings in the current period than the previous period,
    ///     - `.down(n)` if there are `n` fewer meetings,
    ///     - `.neutral` if the number of meetings is unchanged.
    ///
    /// The function determines the current period (e.g., today, this week, this month, this year) based on the `selectedTimeRange` property.
    /// It counts the number of meetings whose `date` falls within the current period and compares it with the number in the immediately preceding equivalent period.
    /// The comparison granularity (day, week, month, year) depends on `selectedTimeRange`.
    func meetingsTrend(_ meetings: [Meeting]) -> Trend {
        let now = Date()
        let calendar = Calendar.current
        
        // Current period meetings
        let currentPeriodMeetings = meetings.filter { meeting in
            switch selectedTimeRange {
                case .today:
                    return calendar.isDateInToday(meeting.date)
                case .week:
                    return calendar.isDate(meeting.date, equalTo: now, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(meeting.date, equalTo: now, toGranularity: .month)
                case .year:
                    return calendar.isDate(meeting.date, equalTo: now, toGranularity: .year)
            }
        }.count
        
        // Previous period meetings
        let previousDate: Date
        switch selectedTimeRange {
            case .today:
                previousDate = calendar.date(byAdding: .day, value: -1, to: now)!
            case .week:
                previousDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
            case .month:
                previousDate = calendar.date(byAdding: .month, value: -1, to: now)!
            case .year:
                previousDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        let previousPeriodMeetings = meetings.filter { meeting in
            switch selectedTimeRange {
                case .today:
                    return calendar.isDate(meeting.date, inSameDayAs: previousDate)
                case .week:
                    return calendar.isDate(meeting.date, equalTo: previousDate, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(meeting.date, equalTo: previousDate, toGranularity: .month)
                case .year:
                    return calendar.isDate(meeting.date, equalTo: previousDate, toGranularity: .year)
            }
        }.count
        
        let difference = currentPeriodMeetings - previousPeriodMeetings
        
        if difference > 0 {
            return .up(difference)
        } else if difference < 0 {
            return .down(abs(difference))
        } else {
            return .neutral
        }
    }
    /// Analyzes the trend in the number of decisions made for the currently selected time range compared to the previous equivalent period.
    ///
    /// - Parameter decisions: An array of `Decision` objects to analyze.
    /// - Returns: A `Trend` value representing the change in the number of decisions:
    ///     - `.up(n)` if there are `n` more decisions made in the current period than the previous period,
    ///     - `.down(n)` if there are `n` fewer decisions,
    ///     - `.neutral` if the number of decisions is unchanged.
    ///
    /// The function determines the current period (e.g., today, this week, this month, this year) based on the `selectedTimeRange` property.
    /// It counts the number of decisions whose `dateMade` falls within the current period and compares it with the number in the immediately preceding equivalent period.
    /// The comparison granularity (day, week, month, year) depends on `selectedTimeRange`.
    func decisionsTrend(_ decisions: [Decision]) -> Trend {
        let now = Date()
        let calendar = Calendar.current
        
        // Current period decisions
        let currentPeriodDecisions = decisions.filter { decision in
            switch selectedTimeRange {
                case .today:
                    return calendar.isDateInToday(decision.dateMade)
                case .week:
                    return calendar.isDate(decision.dateMade, equalTo: now, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(decision.dateMade, equalTo: now, toGranularity: .month)
                case .year:
                    return calendar.isDate(decision.dateMade, equalTo: now, toGranularity: .year)
            }
        }.count
        
        // Previous period decisions
        let previousDate: Date
        switch selectedTimeRange {
            case .today:
                previousDate = calendar.date(byAdding: .day, value: -1, to: now)!
            case .week:
                previousDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
            case .month:
                previousDate = calendar.date(byAdding: .month, value: -1, to: now)!
            case .year:
                previousDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        let previousPeriodDecisions = decisions.filter { decision in
            switch selectedTimeRange {
                case .today:
                    return calendar.isDate(decision.dateMade, inSameDayAs: previousDate)
                case .week:
                    return calendar.isDate(decision.dateMade, equalTo: previousDate, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(decision.dateMade, equalTo: previousDate, toGranularity: .month)
                case .year:
                    return calendar.isDate(decision.dateMade, equalTo: previousDate, toGranularity: .year)
            }
        }.count
        
        let difference = currentPeriodDecisions - previousPeriodDecisions
        
        if difference > 0 {
            return .up(difference)
        } else if difference < 0 {
            return .down(abs(difference))
        } else {
            return .neutral
        }
    }
    
    /// Analyzes the trend in compliance activity for the currently selected time range.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to analyze.
    /// - Returns: A `Trend` value representing the net change in compliance items during the current period:
    ///     - `.up(n)` if there are `n` more new items created than items completed in the period,
    ///     - `.down(n)` if there are `n` more items completed than new items created,
    ///     - `.neutral` if the numbers are equal.
    ///
    /// The function counts:
    ///   - The number of compliance items completed within the current time period (based on their `completedDate`).
    ///   - The number of compliance items created within the current time period (based on their `createdDate`).
    /// The current time period is determined by the `selectedTimeRange` property, which can be `.today`, `.week`, `.month`, or `.year`.
    /// The net change is calculated as the difference between the number of new items created and the number of items completed.
    /// A positive net change indicates a growth in outstanding compliance tasks; a negative net change indicates progress in completion.
    func complianceTrend(_ items: [ProjectTask]) -> Trend {
        // For compliance, we look at completion rate improvement
        //let activeItems = items.filter { !$0.isResolved }
        let completedThisPeriod = items.filter { item in
            guard let completedDate = item.completedDate else { return false }
            let calendar = Calendar.current
            
            switch selectedTimeRange {
                case .today:
                    return calendar.isDateInToday(completedDate)
                case .week:
                    return calendar.isDate(completedDate, equalTo: Date(), toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(completedDate, equalTo: Date(), toGranularity: .month)
                case .year:
                    return calendar.isDate(completedDate, equalTo: Date(), toGranularity: .year)
            }
        }.count
        
        // Compare with new items added
        let newItemsThisPeriod = items.filter { item in
            let calendar = Calendar.current
            
            switch selectedTimeRange {
                case .today:
                    return calendar.isDateInToday(item.createdDate)
                case .week:
                    return calendar.isDate(item.createdDate, equalTo: Date(), toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(item.createdDate, equalTo: Date(), toGranularity: .month)
                case .year:
                    return calendar.isDate(item.createdDate, equalTo: Date(), toGranularity: .year)
            }
        }.count
        
        let netChange = newItemsThisPeriod - completedThisPeriod
        
        if netChange > 0 {
            return .up(netChange)
        } else if netChange < 0 {
            return .down(abs(netChange))
        } else {
            return .neutral
        }
    }
    
    /// Analyzes the trend in overdue compliance items compared to the previous period.
    ///
    /// - Parameter items: An array of `ComplianceItem` objects to analyze.
    /// - Returns: A `Trend` value representing the change in the number of overdue items:
    ///     - `.up(n)` if there are `n` more overdue items in the current period than the previous period,
    ///     - `.down(n)` if there are `n` fewer overdue items,
    ///     - `.neutral` if the number of overdue items is unchanged or there are no overdue items.
    ///
    /// The function compares the current count of overdue compliance items (via `overdueCount(_:)`)
    /// with the count of items that were overdue as of the previous day (unresolved items whose `dueDate` was before yesterday).
    /// A positive difference indicates an increase in overdue items, a negative difference indicates a decrease, and zero indicates no change.
    func overdueTrend(_ items: [ProjectTask]) -> Trend {
        // For overdue, we compare with last period
        let previousOverdueCount = items.filter { item in
            let wasOverdue = item.dueDate < Date().addingTimeInterval(-86400) // Yesterday
            return wasOverdue && !item.isCompleted
        }.count
        
        let difference = overdueCount(items) - previousOverdueCount
        
        if difference > 0 {
            return .up(difference)
        } else if difference < 0 {
            return .down(abs(difference))
        } else {
            return overdueCount(items) > 0 ? .up(overdueCount(items)) : .neutral
        }
    }
}
