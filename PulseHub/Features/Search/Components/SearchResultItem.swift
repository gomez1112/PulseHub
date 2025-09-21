//
//  SearchResultItem.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation

enum SearchResultItem {
    case compliance(ComplianceItem)
    case meeting(Meeting)
    case decision(Decision)
    case observation(ClassroomWalkthrough)
}
