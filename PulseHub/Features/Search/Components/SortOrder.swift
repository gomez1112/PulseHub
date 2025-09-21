//
//  SortOrder.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/4/25.
//

import Foundation

enum SortOrder: String, CaseIterable {
    case relevance = "Relevance"
    case dateAscending = "Date (Old to New)"
    case dateDescending = "Date (New to Old)"
    case name = "Name"
}
