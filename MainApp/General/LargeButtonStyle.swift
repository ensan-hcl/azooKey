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
    @MainActor init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.body.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
