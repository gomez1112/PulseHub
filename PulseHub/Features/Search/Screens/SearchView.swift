//
//  SearchView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(DataModel.self) private var model
    @Environment(NavigationContext.self) private var navigation
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery: String = ""
    @State private var selectedCategory: SearchCategory = .all
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    
    @FocusState private var isSearchFieldFocused: Bool
    
    @Namespace private var animation
    
    @Query private var items: [ProjectTask]
    @Query private var meetings: [Meeting]
    @Query private var decisions: [Decision]
    @Query private var observations: [ClassroomWalkthrough]
    
    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            searchHeader
                .transition(.move(edge: .top).combined(with: .opacity))
            categoryPills
                .transition(.opacity)
            
            if searchQuery.isEmpty {
                ContentUnavailableView("Start Searching...", systemImage: "magnifyingglass.circle.fill", description: Text("Find compliance items, meetings, decisions, and obsevations"))
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            } else if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                searchResultsView
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
            }
            Spacer()
        }
        .navigationTitle("Search")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            isSearchFieldFocused = true
        }
    }
    
    private var searchResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                let results = searchResults
                
                if results.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass.circle", description: Text("Try searching with different keywords"))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    if !results.items.isEmpty {
                        ResultSection(
                            title: "Compliance Items",
                            icon: "checkmark.shield",
                            count: results.items.count
                        ) {
                            ForEach(results.items) { item in
                                Button {
                                    navigation.navigate(to: .task(item))
                                } label: {
                                    SearchResultCard(item: .task(item))
                                        .transition(.asymmetric(
                                            insertion: .push(from: .trailing),
                                            removal: .push(from: .leading)
                                        ))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    if !results.meetings.isEmpty {
                        ResultSection(
                            title: "Meetings",
                            icon: "calendar",
                            count: results.meetings.count
                        ) {
                            ForEach(results.meetings) { meeting in
                                SearchResultCard(item: .meeting(meeting))
                                    .transition(.asymmetric(
                                        insertion: .push(from: .trailing),
                                        removal: .push(from: .leading)
                                    ))
                            }
                        }
                    }
                    
                    if !results.decisions.isEmpty {
                        ResultSection(
                            title: "Decisions",
                            icon: "lightbulb",
                            count: results.decisions.count
                        ) {
                            ForEach(results.decisions) { decision in
                                Button {
                                    navigation.navigate(to: .decision(decision))
                                } label: {
                                    SearchResultCard(item: .decision(decision))
                                        .transition(.asymmetric(
                                            insertion: .push(from: .trailing),
                                            removal: .push(from: .leading)
                                        ))
                                    
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    if !results.observations.isEmpty {
                        ResultSection(
                            title: "Observations",
                            icon: "eye",
                            count: results.observations.count
                        ) {
                            ForEach(results.observations) { observation in
                                Button {
                                    navigation.navigate(to: .observation(observation))
                                } label: {
                                    SearchResultCard(item: .observation(observation))
                                        .transition(.asymmetric(
                                            insertion: .push(from: .trailing),
                                            removal: .push(from: .leading)
                                        ))
                                }
                                .buttonStyle(.plain)
                                
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var searchHeader: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.body.weight(.medium))
                .symbolEffect(.bounce, value: isSearching)
            
            TextField("Search Everything...", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(.body)
                .submitLabel(.search)
                .focused($isSearchFieldFocused)
                .onChange(of: searchQuery) { oldValue, newValue in
                    searchTask?.cancel()
                    
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        if !Task.isCancelled {
                            withAnimation {
                                isSearching = false
                            }
                        }
                    }
                    if !newValue.isEmpty {
                        withAnimation {
                            isSearching = true
                        }
                    }
                }
                .onSubmit {
#if !os(macOS)
                    AppTheme.impact(.light)
#endif
                }
            
            if !searchQuery.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        searchQuery = ""
                        #if !os(macOS)
                        AppTheme.selection()
                        #endif
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.body)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding()
    }
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(SearchCategory.allCases) { category in
                    CategoryPill(category: category, isSelected: selectedCategory == category, namespace: animation) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding()
        }
    }
    private var searchResults: SearchResults {
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty {
            return SearchResults()
        }
        
        let filteredItems = items.filter { item in
            item.title.localizedCaseInsensitiveContains(query) ||
            (item.detail ?? "").localizedCaseInsensitiveContains(query)
        }
        
        let filteredMeetings = meetings.filter { meeting in
            meeting.title.localizedCaseInsensitiveContains(query) ||
            meeting.attendees.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        
        let filteredDecisions = decisions.filter { decision in
            decision.title.localizedCaseInsensitiveContains(query) ||
            (decision.detail ?? "").localizedCaseInsensitiveContains(query) ||
            (decision.rationale).localizedCaseInsensitiveContains(query)
        }
        
        let filteredObservations = observations.filter { observation in
            observation.teacherName.localizedCaseInsensitiveContains(query) ||
            observation.subject.localizedCaseInsensitiveContains(query)
        }
        
        return SearchResults(
            items: selectedCategory == .all || selectedCategory == .task ? filteredItems : [],
            meetings: selectedCategory == .all || selectedCategory == .meetings ? filteredMeetings : [],
            decisions: selectedCategory == .all || selectedCategory == .decisions ? filteredDecisions : [],
            observations: selectedCategory == .all || selectedCategory == .observations ? filteredObservations : []
        )
    }
}

#Preview(traits: .previewData) {
    SearchView()
}

