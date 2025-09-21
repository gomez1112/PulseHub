//
//  ComplianceEntry.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import WidgetKit


struct ComplianceEntry: TimelineEntry {
    let date: Date
    let items: [ComplianceItem]
    
    var overdueCount: Int {
        items.filter { $0.isOverdue }.count
    }
    
    var todayCount: Int {
        items.filter { Calendar.current.isDateInToday($0.dueDate) }.count
    }
}
