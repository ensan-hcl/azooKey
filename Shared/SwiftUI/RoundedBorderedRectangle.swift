//
//  RoundedBorderedRectangle.swift
//  Keyboard
//
//  Created by β α on 2021/02/05.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct RoundedBorderedRectangle: View {
    private let cornerRadius: CGFloat
    private let fillColor: Color
    private let borderColor: Color
    private let borderWidth: CGFloat

    init(cornerRadius: CGFloat, fillColor: Color = .clear, borderColor: Color = .clear, borderWidth: CGFloat = 1) {
        self.cornerRadius = cornerRadius
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    private var base: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius)
    }

    var body: some View {
        ZStack {
            base.fill(fillColor)
            base.stroke(borderColor, lineWidth: borderWidth)
        }
    }

}
