//
//  iOSWidgetPulseHubBundle.swift
//  iOSWidgetPulseHub
//
//  Created by Gerard Gomez on 9/7/25.
//

import WidgetKit
import SwiftUI

@main
struct iOSWidgetPulseHubBundle: WidgetBundle {
    var body: some Widget {
        ComplianceWidget()
        ScheduleWidget()
        DecisionWidget()

    }
}
