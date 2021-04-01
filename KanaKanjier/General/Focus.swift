//
//  Focus.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
struct FocusViewModifier: ViewModifier {
    let color: Color
    let focused: Bool

    func body(content: Content) -> some View {
        let shadowColor = focused ? color:.clear
        let shadowRadius: CGFloat = focused ? 0.5:.zero
        return content
            .shadow(color: shadowColor, radius: shadowRadius, x: 1)
            .shadow(color: shadowColor, radius: shadowRadius, x: -1)
            .shadow(color: shadowColor, radius: shadowRadius, y: 1)
            .shadow(color: shadowColor, radius: shadowRadius, y: -1)
    }
}

extension View {
    func focus(_ color: Color, focused: Bool) -> some View {
        self.modifier(FocusViewModifier(color: color, focused: focused))
    }
}
