//
//  StrokeAndFill.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/26.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension Shape {
    func strokeAndFill<FillContent: ShapeStyle, StrokeContent: ShapeStyle>(fillContent: FillContent, strokeContent: StrokeContent, lineWidth: CGFloat) -> some View {
        ZStack{
            self.fill(fillContent)
            self.stroke(strokeContent, lineWidth: lineWidth)
        }
    }
}
