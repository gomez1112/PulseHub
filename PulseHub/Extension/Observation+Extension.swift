//
//  Observation+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/13/25.
//

import Foundation

extension DataModel {
    
    var isValid: Bool {
        isValid(trimming: teacherName) && isValid(trimming: subject)
    }
    
    func saveObservation(teacherName: String, date: Date = Date(), components: [RubricComponent], subject: String, gradeLevel: GradeLevel, observationType: ObservationType, duration: Int, overallRating: DanielsonScore, followUpRequired: Bool, followUpDate: Date?, selectedMeeting: Meeting?) {
        let observation = ClassroomWalkthrough(teacherName: teacherName.trimmingCharacters(in: .whitespacesAndNewlines), date: Date(), components: components)
        observation.subject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        observation.gradeLevel = gradeLevel
        observation.observationType = observationType
        observation.duration = duration
        observation.followUpRequired = followUpRequired
        observation.followUpDate = followUpRequired ? followUpDate : nil
        observation.meeting = selectedMeeting
        components.forEach { $0.observation = observation }
        save(observation)
    }
}
