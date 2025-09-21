//
//  Observation.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation
import SwiftData

/// A model representing a classroom walkthrough observation for a teacher. 
///
/// Each `ClassroomWalkthrough` instance stores information about a specific observation, 
/// such as the teacher's name, the date of the walkthrough, the subject, grade level, 
/// observation type, duration, and overall rating based on the Danielson framework.
///
/// The walkthrough can be associated with multiple rubric components, each scored individually, 
/// and can be linked optionally to a follow-up meeting. The class also provides computed properties 
/// for determining the overall average rubric score and a human-readable description of the overall rating.
///
/// - Properties:
///   - teacherName: The name of the teacher being observed.
///   - date: The date the walkthrough took place.
///   - subject: The subject being taught during the observation.
///   - gradeLevel: The grade level of the observed class.
///   - observationType: The type of observation (formal, informal, walkthrough, follow-up).
///   - duration: The length of the observation in minutes.
///   - overallRating: The summary Danielson score for the observation.
///   - followUpRequired: Whether a follow-up is required for this observation.
///   - followUpDate: The scheduled date for any required follow-up, if applicable.
///   - components: The scored rubric components associated with this walkthrough.
///   - meeting: An optional linked meeting related to this observation (such as a follow-up discussion).
///
/// - Computed Properties:
///   - overallAverage: The average numeric value of all rubric component scores, or 0 if no components exist.
///   - overallRatingDescription: A textual summary of the overall rating, derived from the average score.
///
/// - Sample Data:
///   - Provided extensions give sample walkthroughs and components for preview or demonstration purposes.
@Model
final class ClassroomWalkthrough {
    var teacherName = ""
    var date = Date()
    var subject = ""
    var gradeLevel = GradeLevel.ninth
    var observationType = ObservationType.followUp
    var duration = 0
    var overallRating = DanielsonScore.developing
    var followUpRequired = false
    var followUpDate: Date?
    
    /// The average numeric value of all rubric component scores in this walkthrough.
    ///
    /// This value is calculated by summing the `numericValue` of each `RubricComponent` score
    /// in the `components` array, and dividing by the total number of components. If there are no
    /// components associated with this walkthrough, the average will be 0.
    ///
    /// - Returns: A `Double` representing the average numeric rubric score, or 0 if no components exist.
    @MainActor
    var overallAverage: Double {
        guard let components, !components.isEmpty else { return 0 }
        let total = components.map { Double($0.score.numericValue) }.reduce(0, +)
        return total / Double(components.count)
    }
    
    /// A human-readable description of the overall Danielson rating for this observation.
    ///
    /// This computed property interprets the `overallAverage` rubric score and maps it
    /// to a textual summary based on standard Danielson scoring ranges:
    /// - 1..<2: "Ineffective"
    /// - 2..<3: "Developing"
    /// - 3..<4: "Effective"
    /// - 4..<5: "Highly Effective"
    /// - Default: "Ineffective"
    ///
    /// - Returns: A `String` summary of the overall Danielson rating.
    @MainActor
    var overallRatingDescription: String {
        switch overallAverage {
            case 1..<2: "Ineffective"
            case 2..<3: "Developing"
            case 3..<4: "Effective"
            case 4..<5: "Highly Effective"
            default: "Ineffective"
        }
    }
    /// The scored rubric components
    @Relationship(deleteRule: .cascade, inverse: \RubricComponent.observation)
    var components: [RubricComponent]? = []

    var meeting: Meeting?

    init(
        teacherName: String,
        date: Date = Date(),
        components: [RubricComponent] = []
    ) {
        self.teacherName = teacherName
        self.date = date
        self.components = components
    }
}
enum GradeLevel: String, CaseIterable, Codable {
    case ninth = "9th"
    case tenth = "10th"
    case eleventh = "11th"
    case twelfth = "12th"
}
enum ObservationType: String, CaseIterable, Codable {
    case formal = "Formal"
    case informal = "Informal"
    case walkthrough = "Walkthrough"
    case followUp = "Follow-up"
}

// MARK: - Sample Data

@MainActor
extension ClassroomWalkthrough {
    static let sampleComponents: [RubricComponent] = [
        RubricComponent(
            domain: .classroomEnvironment,
            componentNumber: "2a",
            detail: "Creates an environment of respect and rapport",
            score: .effective,
            comments: "Students were respectful and attentive."
        ),
        RubricComponent(
            domain: .instruction,
            componentNumber: "3c",
            detail: "Engaging students in learning",
            score: .developing,
            comments: "Most students were engaged, but some off-task behavior noted."
        )
    ]

    static let samples: [ClassroomWalkthrough] = [
        ClassroomWalkthrough(
            teacherName: "Ms. Anderson",
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
            components: sampleComponents
        ),
        ClassroomWalkthrough(
            teacherName: "Mr. Lee",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            components: [sampleComponents[1]]
        )
    ]
}

