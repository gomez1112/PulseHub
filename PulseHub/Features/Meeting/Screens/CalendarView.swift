//
//  CalendarView.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/5/25.
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasMeetings: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var isToday: Bool { Calendar.current.isDateInToday(date) }
    
    var isValidDate: Bool { date != Date.distantPast }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isValidDate {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.callout.weight(isToday ? .bold : .regular))
                        .foregroundStyle(isSelected ? .white : (isToday ? .orange : .primary))
                    
                    if hasMeetings {
                        Circle()
                            .fill(isSelected ? .white : .orange)
                            .frame(width: 4, height: 4)
                            .offset(y: 16)
                    }
                }
            }
            .frame(width: 40, height: 40)
            .background {
                if isSelected && isValidDate {
                    Circle()
                        .fill(Color.accentColor)
                } else if isToday && isValidDate {
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(!isValidDate)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }
    }
}

#Preview {
    CalendarDayView(date: Date(), isSelected: true, hasMeetings: true, action: {})
}
