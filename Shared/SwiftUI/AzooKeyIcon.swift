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
    private let color: Color
    private let arguments: Arguments
    enum Color {
        case auto
        case color(SwiftUI.Color)
    }
    private enum Arguments {
        case relative(size: CGFloat, textStyle: Font.TextStyle)
        case fixed(size: CGFloat)
    }
    init(fontSize: CGFloat, relativeTo textStyle: Font.TextStyle = .body, color: Color = .auto) {
        self.color = color
        self.arguments = .relative(size: fontSize, textStyle: textStyle)
    }

    init(fixedSize: CGFloat, color: Color = .auto) {
        self.color = color
        self.arguments = .fixed(size: fixedSize)
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
        switch self.arguments {
        case let .relative(size: size, textStyle: textStyle):
            Text("1")
                .font(Design.fonts.azooKeyIconFont(size, relativeTo: textStyle))
                .foregroundColor(foregroundColor)
        case let .fixed(size: size):
            Text("1")
                .font(Design.fonts.azooKeyIconFont(fixedSize: size))
                .foregroundColor(foregroundColor)
        }
    }
}

