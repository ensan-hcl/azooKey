//
//  AzooKeyIconView.swift
//  AzooKeyIconView
//
//  Created by β α on 2021/07/22.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct AzooKeyIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    private var fontSize: CGFloat
    private var color: Color
    enum Color {
        case auto
        case color(SwiftUI.Color)
    }
    init(fontSize: CGFloat, color: Color = .auto) {
        self.fontSize = fontSize
        self.color = color
    }
    private var foregroundColor: SwiftUI.Color {
        switch self.color {
        case .auto:
            switch colorScheme {
            case .light:
                return .init(red: 0.398, green: 0.113, blue: 0.218)
            case .dark:
                return .white
            @unknown default:
                return .init(red: 0.398, green: 0.113, blue: 0.218)
            }
        case let .color(color):
            return color
        }
    }

    var body: some View {
        if let font = Design.fonts.azooKeyIconFont(fontSize) {
            Text("1")
                .font(font)
                .foregroundColor(foregroundColor)
        }
    }
}

