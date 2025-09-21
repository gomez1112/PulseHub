//
//  DecisionListView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct DecisionListView: View {
    let decisions: [Decision]
    
    var body: some View {
        List {
            ForEach(decisions) { decision in
                NavigationLink(value: decision) {
                    DecisionRow(decision: decision)
                }
            }
        }
    }
}

#Preview {
    DecisionListView(decisions: Decision.samples)
}
