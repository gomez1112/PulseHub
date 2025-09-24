//
//  SearchResultItem.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation

enum SearchResultItem {
    case task(ProjectTask)
    case meeting(Meeting)
    case decision(Decision)
    case observation(ClassroomWalkthrough)
}
