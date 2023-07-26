//
//  LargeButtonStyle.swift
//  LargeButtonStyle
//
//  Created by ensan on 2021/07/23.
//  Copyright © 2021 ensan. All rights reserved.
//

import SwiftUI

struct LargeButtonStyle: ButtonStyle {
    private let backgroundColor: Color
    private let screenWidth: CGFloat
    @MainActor init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        self.screenWidth = UIScreen.main.bounds.width
    }
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.body.bold())
            .padding()
            .frame(width: screenWidth * 0.9)
            .background(
                RoundedRectangle(cornerRadius: screenWidth / 4.8 * 0.17)
                    .fill(backgroundColor)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
