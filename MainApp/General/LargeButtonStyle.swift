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
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        let width = UIScreen.main.bounds.width
        configuration
            .label
            .font(.body.bold())
            .padding()
            .frame(width: width * 0.9)
            .background(
                RoundedRectangle(cornerRadius: width / 4.8 * 0.17)
                    .fill(backgroundColor)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
