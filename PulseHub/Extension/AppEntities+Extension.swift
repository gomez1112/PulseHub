//
//  AppEntities+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import Foundation
import SwiftData

extension DataModel {
    
    private func fetchEntities<M: PersistentModel, E>( of _: M.Type, predicate: Predicate<M> = #Predicate { _ in true }, sortBy: [SortDescriptor<M>] = [], limit: Int? = nil, map: (M) -> E) throws -> [E] {
        var descriptor = FetchDescriptor<M>(predicate: predicate, sortBy: sortBy)
        descriptor.fetchLimit = limit
        let models = try context.fetch(descriptor)
        return models.map(map)
    }
    
    private func count<M: PersistentModel>(_ : M.Type, predicate: Predicate<M> = #Predicate { _ in true }) throws -> Int {
        let descriptor = FetchDescriptor<M>(predicate: predicate)
        return try context.fetchCount(descriptor)
    }
    func complianceItemEntities(matching predicate: Predicate<ComplianceItem> = #Predicate { _ in true }, sortBy: [SortDescriptor<ComplianceItem>] = [SortDescriptor(\.dueDate, order: .reverse)], limit: Int? = nil) throws -> [ComplianceItemEntity] {
        try fetchEntities(of: ComplianceItem.self,predicate: predicate,sortBy: sortBy,limit: limit, map: ComplianceItemEntity.init)
    }
    
    func complianceItemCount(matching predicate: Predicate<ComplianceItem> = #Predicate { _ in true }) throws -> Int {
        try count(ComplianceItem.self, predicate: predicate)
    }
    
    func suggest5ComplianceItemEntities() throws -> [ComplianceItemEntity] {
        try complianceItemEntities(limit: 5)
    }
    
    // MARK: - Decision
    
    func decisionEntities(matching predicate: Predicate<Decision> = #Predicate { _ in true },sortBy: [SortDescriptor<Decision>] = [SortDescriptor(\.dateMade, order: .reverse)],limit: Int? = nil) throws -> [DecisionEntity] {
        try fetchEntities(
            of: Decision.self,
            predicate: predicate,
            sortBy: sortBy,
            limit: limit,
            map: DecisionEntity.init
        )
    }
    
    func decisionItemCount(matching predicate: Predicate<Decision> = #Predicate { _ in true }) throws -> Int {
        try count(Decision.self, predicate: predicate)
    }
    
    func suggest5DecisionEntities() throws -> [DecisionEntity] {
        try decisionEntities(limit: 5)
    }
    
    // MARK: - Meeting
    
    func meetingEntities(matching predicate: Predicate<Meeting> = #Predicate { _ in true }, sortBy: [SortDescriptor<Meeting>] = [SortDescriptor(\.date, order: .reverse)],limit: Int? = nil) throws -> [MeetingEntity] {
        try fetchEntities(of: Meeting.self, predicate: predicate, sortBy: sortBy, limit: limit,map: MeetingEntity.init)
    }
    
    // (Was previously misnamed `decisionItemCount`.)
    func meetingItemCount(matching predicate: Predicate<Meeting> = #Predicate { _ in true }) throws -> Int {
        try count(Meeting.self, predicate: predicate)
    }
    
    func suggest5MeetingEntities() throws -> [MeetingEntity] {
        try meetingEntities(limit: 5)
    }
}
