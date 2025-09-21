//
//  View+Extension.swift
//  PulseHub
//
//  Created by Gerard Gomez on 7/3/25.
//

import SwiftUI

extension View {
    
    /// Applies a card-style appearance to the view.
    ///
    /// This view modifier adds rounded corners, a subtle shadow, and other 
    /// visual treatments to give the view a "card" look and feel. The appearance 
    /// can be adjusted based on whether the card is pressed or not.
    ///
    /// - Parameter isPressed: A Boolean value indicating if the card is in a pressed state. 
    ///   When `true`, the card may appear more subdued (such as with a smaller shadow or 
    ///   slight scaling) to provide press feedback. Default is `false`.
    /// - Returns: A view modified with a card-style appearance.
    func cardStyle(isPressed: Bool = false) -> some View {
        modifier(CardStyle(isPressed: isPressed))
    }
}
