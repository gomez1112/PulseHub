//
//  SearchResults.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation

struct SearchResults {
    var items: [ProjectTask] = []
    var meetings: [Meeting] = []
    var decisions: [Decision] = []
    var observations: [ClassroomWalkthrough] = []
    
    var isEmpty: Bool {
        items.isEmpty &&
        meetings.isEmpty &&
        decisions.isEmpty &&
        observations.isEmpty
    }
    var totalCount: Int {
        items.count + meetings.count + decisions.count + observations.count
    }
}
