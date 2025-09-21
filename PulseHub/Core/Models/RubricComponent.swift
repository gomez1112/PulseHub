//
//  RubricComponent.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData

/// A data model representing a single component within the Danielson rubric,
/// typically used for evaluating classroom instruction or teacher effectiveness.
/// 
/// - Note: Each `RubricComponent` instance is associated with a specific Danielson domain,
///   a unique component number (e.g., "1a"), descriptive details, an evaluation score,
///   optional comments, and may optionally reference a related `ClassroomWalkthrough`.
///
/// Properties:
/// - `domain`: The Danielson domain to which this rubric component belongs.
/// - `componentNumber`: The unique identifier for the rubric component (e.g., "1a").
/// - `detail`: A textual description of the rubric component.
/// - `score`: The evaluation score for this component, represented by a `DanielsonScore`.
/// - `comments`: Optional supplementary remarks or observations.
/// - `observation`: An optional relationship to a `ClassroomWalkthrough` this component is part of.
///
/// Usage:
/// - Instances can be initialized with all core fields, and optional comments.
/// - Contains a static `samples` array that provides predefined example components for previews or testing.
@Model
final class RubricComponent {
    var domain = DanielsonDomain.classroomEnvironment
    var componentNumber = ""   // e.g. "1a", "3c"
    var detail = ""          // description of that component
    var score = DanielsonScore.developing      // rubric level
    var comments: String?
    
    var observation: ClassroomWalkthrough?

    init(
        domain: DanielsonDomain,
        componentNumber: String,
        detail: String,
        score: DanielsonScore,
        comments: String? = nil
    ) {
        self.domain = domain
        self.componentNumber = componentNumber
        self.detail = detail
        self.score = score
        self.comments = comments
    }
}

// MARK: - Sample Data
@MainActor
extension RubricComponent {
    static let samples: [RubricComponent] = [
        RubricComponent(
            domain: .planningPreparation,
            componentNumber: "1a",
            detail: "Demonstrating Knowledge of Content and Pedagogy",
            score: .highlyEffective,
            comments: "Excellent use of differentiated instruction."
        ),
        RubricComponent(
            domain: .classroomEnvironment,
            componentNumber: "2b",
            detail: "Establishing a Culture for Learning",
            score: .effective,
            comments: "Students were motivated and took ownership of their work."
        ),
        RubricComponent(
            domain: .instruction,
            componentNumber: "3c",
            detail: "Engaging Students in Learning",
            score: .developing,
            comments: "Some students needed additional support to stay engaged."
        )
    ]
}
