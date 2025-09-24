//
//  ObservationView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 9/23/25.
//

import SwiftData
import SwiftUI

struct ObservationView: View {
    @Environment(NavigationContext.self) private var navigation
    @Environment(DataModel.self) private var model
    
    @Query(sort: \ClassroomWalkthrough.date, order: .reverse) private var observations: [ClassroomWalkthrough]
    @State private var searchText = ""
    
    private var filteredObservations: [ClassroomWalkthrough] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return observations }
        return observations.filter {
            $0.teacherName.localizedCaseInsensitiveContains(searchText) ||
            $0.subject.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var groupedObservations: [String: [ClassroomWalkthrough]] {
        Dictionary(grouping: filteredObservations, by: { $0.teacherName })
    }
    
    private var sortedTeacherNames: [String] {
        groupedObservations.keys.sorted()
    }
    
    var body: some View {
        Group {
            if observations.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(sortedTeacherNames, id: \.self) { teacherName in
                        Section(header: Text(teacherName).font(.headline)) {
                            ForEach(groupedObservations[teacherName] ?? []) { observation in
                                ObservationRow(observation: observation)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        navigation.navigate(to: .observation(observation))
                                    }
                            }
                        }
                    }
                }
                #if !os(macOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .background(Color.systemBackgroundCompat)
        .navigationTitle("Observations")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .searchable(text: $searchText, prompt: "Search by Teacher or Subject")
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Observations Yet", systemImage: "eye.slash")
        } description: {
            Text("Tap the plus button to add your first classroom observation.")
        } actions: {
            Button("Add Observation") {
                navigation.presentSheet(.addObservation)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview(traits: .previewData) {
    ObservationView()
}
