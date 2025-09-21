//
//  DanielsonDomain.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation

/// An enumeration that represents the four domains of the Danielson Framework for Teaching.
///
/// The Danielson Framework is a widely used model for evaluating and supporting effective teaching.
/// Each case corresponds to one of the core domains:
///
/// - `planningPreparation`: The teacher's ability to plan and prepare for instruction.
/// - `classroomEnvironment`: Establishing and maintaining a productive classroom environment.
/// - `instruction`: The implementation of effective instructional practices.
/// - `professionalResponsibilities`: The teacher's professionalism and contributions outside of instruction.
///
/// Conforms to `String` (for raw values), `Codable` (for encoding/decoding), `CaseIterable` (for getting all cases),
/// and `Identifiable` (using the enum value as its identifier).
enum DanielsonDomain: String, Codable, CaseIterable, Identifiable {
    case planningPreparation        = "Planning & Preparation"
    case classroomEnvironment       = "Classroom Environment"
    case instruction                = "Instruction"
    case professionalResponsibilities = "Professional Responsibilities"
    
    var components: [String] {
        switch self {
            case .planningPreparation: ["1a. Demonstrating Knowledge of Content and Pedagogy", "1e. Designing Coherent Instruction"]
            case .classroomEnvironment: ["2a. Creating an Environment of Respect and Rapport", "2d. Managing Student Behavior"]
            case .instruction: ["3b. Using Questioning and Discussion Techniques", "3c. Engaging Students in Learning", "3d. Using Assessment in Instruction"]
            case .professionalResponsibilities: ["4e. Growing and Developing Professionally"]
        }
    }
    var summary: String {
        switch self {
            case .planningPreparation:
                    """
                    Effective teachers plan and prepare for lessons
                    using their extensive knowledge of the content area,
                    the relationships among different strands within the
                    content and between the subject and other
                    disciplines, and their students’ prior understanding
                    of the subject. Instructional outcomes are clear,
                    represent important learning in the subject, and are
                    aligned to the curriculum. The instructional design
                    includes learning activities that are well sequenced
                    and require all students to think, problem solve,
                    inquire, and defend conjectures and opinions.
                    Effective teachers design formative assessments to
                    monitor learning, and they provide the information
                    needed to differentiate instruction. Measures of
                    student learning align with the curriculum, enabling
                    students to demonstrate their understanding in
                    more than one way.
                    """
            case .classroomEnvironment:
                    """
                    Effective teachers organize their classrooms so that
                    all students can learn. They maximize instructional
                    time and foster respectful interactions with and
                    among students, ensuring that students find the
                    classroom a safe place to take intellectual risks.
                    Students themselves make a substantive
                    contribution to the effective functioning of the
                    class by assisting with classroom procedures,
                    ensuring effective use of physical space, and
                    supporting the learning of classmates. Students
                    and teachers work in ways that demonstrate their
                    belief that hard work will result in higher levels of
                    learning. Student behavior is consistently
                    appropriate, and the teacher’s handling of
                    infractions is subtle, preventive, and respectful of
                    students’ dignity.
                    """
            case .instruction:
                    """
                    In the classrooms of accomplished teachers, all
                    students are highly engaged in learning. They make
                    significant contributions to the success of the class
                    through participation in high-level discussions and
                    active involvement in their learning and the learning
                    of others. Teacher explanations are clear and invite
                    student intellectual engagement. The teacher’s
                    feedback is specific to learning goals and rubrics
                    and offers concrete suggestions for improvement.
                    As a result, students understand their progress in
                    learning the content and can explain the learning
                    goals and what they need to do in order to
                    improve. Effective teachers recognize their
                    responsibility for student learning and make
                    adjustments, as needed, to ensure student success.
                    """
            case .professionalResponsibilities:
                    """
                    Accomplished teachers have high ethical standards
                    and a deep sense of professionalism, focused on
                    improving their own teaching and supporting the
                    ongoing learning of colleagues. Their record-keeping
                    systems are efficient and effective, and they
                    communicate with families clearly, frequently, and
                    with cultural sensitivity. Accomplished teachers
                    assume leadership roles in both school and LEA
                    projects, and they engage in a wide range of
                    professional development activities to strengthen
                    their practice. Reflection on their own teaching
                    results in ideas for improvement that are shared
                    across professional learning communities and
                    contribute to improving the practice of all.
                    """
        }
    }
    
    var id: Self { self }
}
