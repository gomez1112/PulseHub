//
//  Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import Foundation

extension Date {
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    var isValidDate: Bool {
        self != Date.distantPast
    }
}

