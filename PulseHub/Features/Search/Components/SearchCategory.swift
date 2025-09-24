//
//  SearchCategory.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation

enum SearchCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case task = "Tasks"
    case meetings = "Meetings"
    case decisions = "Decisions"
    case observations = "Observations"
    
    var icon: String {
        switch self {
            case .all: "square.grid.2x2"
            case .task: "checkmark.shield"
            case .meetings: "calendar"
            case .decisions: "lightbulb"
            case .observations: "eye"
        }
    }
    
    var id: Self { self }
}
