//
//  Decision+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/6/25.
//

import Foundation

extension DataModel {
    
    /// Determines whether both the title and rationale strings are valid after trimming whitespace.
    ///
    /// This method trims the provided `title` and `rationale` strings and checks if both meet the validity criteria as defined by `isValid(trimming:)`.
    ///
    /// - Parameters:
    ///   - title: The title string to validate.
    ///   - rationale: The rationale string to validate.
    /// - Returns: `true` if both the trimmed title and rationale are valid; otherwise, `false`.
    func isValid(title: String, rationale: String) -> Bool {
        isValid(trimming: title) && isValid(trimming: rationale)
    }
    
    /// Saves a new `Decision` to the data model.
    ///
    /// This method creates a new `Decision` instance with the provided parameters, including its title, detail, next steps, associated meeting, rationale, and impact level. The decision is then saved to persistent storage.
    ///
    /// - Parameters:
    ///   - title: The title of the decision.
    ///   - detail: An optional description providing additional details about the decision.
    ///   - nextStep: An optional string describing the next steps following the decision.
    ///   - meeting: The associated `Meeting` instance, if any, where the decision was made or discussed.
    ///   - rationale: The reasoning or justification behind the decision.
    ///   - impact: The `ImpactLevel` categorizing the significance of the decision.
    func saveDecision(title: String, detail: String?, nextStep: String?, meeting: Meeting?, rationale: String, impact: ImpactLevel) {
        let decision = Decision(title: title, detail: detail, nextSteps:  nextStep, meeting: meeting)
        decision.rationale = rationale
        decision.impact = impact
        save(decision)
    }
    /// Filters an array of `Decision` instances based on search text and optional effectiveness and impact criteria.
    ///
    /// This method first applies a case-insensitive search filter to the given decisions, matching against the decision's title, detail, or rationale. If the `searchText` parameter is non-empty, only decisions containing the search text in any of those fields are included. Next, if filtering criteria for effectiveness (`filterEffectiveness`) or impact (`filterImpact`) are set on the data model, those are applied in sequence to further restrict the results.
    ///
    /// - Parameters:
    ///   - searchText: The search string used to filter decisions by title, detail, or rationale. If empty, this filter is not applied.
    ///   - decisions: The array of `Decision` objects to filter.
    /// - Returns: An array of `Decision` instances that match the provided search text and any optional effectiveness and impact filters.
    func filtered(_ searchText: String, _ decisions: [Decision]) -> [Decision] {
        var result = decisions
        
        if !searchText.isEmpty {
            result = result.filter { decision in
                decision.title.localizedCaseInsensitiveContains(searchText) ||
                (decision.detail ?? "").localizedCaseInsensitiveContains(searchText) ||
                decision.rationale.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let effectiveness = filterEffectiveness {
            result = result.filter { $0.wasEffective == effectiveness }
        }
        
        if let impact = filterImpact {
            result = result.filter { $0.impact == impact }
        }
        
        return result
    }
    
    /// Calculates the number of decisions classified as effective, ineffective, or pending.
    ///
    /// This method examines the `wasEffective` property of each decision in the provided array and counts how many are marked as effective (`true`), ineffective (`false`), or pending (`nil`). It returns a tuple with the counts for each category.
    ///
    /// - Parameter decisions: An array of `Decision` instances to analyze.
    /// - Returns: A tuple containing the counts of effective, ineffective, and pending decisions, respectively.
    func effectivenessStats(_ decisions: [Decision]) -> (effective: Int, ineffective: Int, pending: Int) {
        let effective = decisions.filter { $0.wasEffective == true }.count
        let ineffective = decisions.filter { $0.wasEffective == false }.count
        let pending = decisions.filter { $0.wasEffective == nil }.count
        return (effective, ineffective, pending)
    }
    
    /// Computes a breakdown of decisions by their impact level.
    ///
    /// This method iterates through all possible `ImpactLevel` cases and counts the number of decisions in the provided array that correspond to each impact level.
    /// It returns an array of tuples, where each tuple contains an `ImpactLevel` case and the count of decisions classified under that impact level.
    ///
    /// - Parameter decisions: An array of `Decision` instances to categorize by impact level.
    /// - Returns: An array of tuples, each containing an `ImpactLevel` and the corresponding count of decisions with that impact.
    func impactBreakdown(_ decisions: [Decision]) -> [(ImpactLevel, Int)] {
        ImpactLevel.allCases.map { level in
            (level, decisions.filter { $0.impact == level }.count)
        }
    }
}
