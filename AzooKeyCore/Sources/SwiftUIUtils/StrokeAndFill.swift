//
//  StrokeAndFill.swift
//  azooKey
//
//  Created by ensan on 2021/02/26.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public extension Shape {
    func strokeAndFill(fillContent: some ShapeStyle, strokeContent: some ShapeStyle, lineWidth: CGFloat) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(strokeContent, lineWidth: lineWidth)
        }
    }
}
