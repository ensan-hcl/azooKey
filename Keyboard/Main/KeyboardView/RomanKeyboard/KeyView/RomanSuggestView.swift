//
//  RomanSuggestView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum VariationsViewDirection{
    case center, right, left
    
    var alignment: Alignment{
        switch self{
        case .center: return .center
        case .right: return .leading
        case .left: return .trailing
        }
    }
    
    var edge: Edge.Set{
        switch self{
        case .center: return []
        case .right: return .leading
        case .left: return .trailing
        }
    }

}

struct RomanSuggestView{
    static func expandedPath(rdw: CGFloat, ldw: CGFloat, width: CGFloat) -> some Shape {
        return Path { path in
            path.move(to: CGPoint(x: 122, y: 281))
            path.addLine(to: CGPoint(x: 53, y: 281))
            path.addCurve(
                to: CGPoint(x: 33, y: 261),
                control1: CGPoint(x: 40, y: 281),
                control2: CGPoint(x: 33, y: 274)
            )
            path.addLine(to: CGPoint(x: 33, y: 173))
            path.addCurve(
                to: CGPoint(x: 26, y: 148),
                control1: CGPoint(x: 33, y: 164),
                control2: CGPoint(x: 32, y: 157)
            )
            path.addLine(to: CGPoint(x: 7-ldw, y: 121))
            path.addCurve(
                to: CGPoint(x: 0-ldw, y: 96),
                control1: CGPoint(x: 1-ldw, y: 113),
                control2: CGPoint(x: 0-ldw, y: 106)
            )
            path.addLine(to: CGPoint(x: 0-ldw, y: 20))
            path.addCurve(
                to: CGPoint(x: 20-ldw, y: 0),
                control1: CGPoint(x: 0-ldw, y: 7),
                control2: CGPoint(x: 7-ldw, y: 0)
            )
            path.addLine(to: CGPoint(x: 155+rdw, y: 0))
            path.addCurve(
                to: CGPoint(x: 175+rdw, y: 20),
                control1: CGPoint(x: 168+rdw, y: 0),
                control2: CGPoint(x: 175+rdw, y: 7)
            )
            path.addLine(to: CGPoint(x: 175+rdw, y: 96))
            path.addCurve(
                to: CGPoint(x: 168+rdw, y: 121),
                control1: CGPoint(x: 175+rdw, y: 106),
                control2: CGPoint(x: 174+rdw, y: 113)
            )
            path.addLine(to: CGPoint(x: 149, y: 148))
            path.addCurve(
                to: CGPoint(x: 142, y: 173),
                control1: CGPoint(x: 143, y: 156),
                control2: CGPoint(x: 142, y: 164)
            )
            path.addLine(to: CGPoint(x: 142, y: 261))
            path.addCurve(
                to: CGPoint(x: 122, y: 281),
                control1: CGPoint(x: 142, y: 274),
                control2: CGPoint(x: 135, y: 281)
            )
        }.offsetBy(dx:-175/2 + width/2, dy: 0 )
        .scale(x: width/109, y: (Design.shared.keyViewSize.height*2+Design.shared.verticalSpacing)/281, anchor: .top)
    }
    
    static func scaleToFrameSize(keyWidth: CGFloat, scale_y: CGFloat, color: Color) -> some View {
        let height = (Design.shared.keyViewSize.height*2 + Design.shared.verticalSpacing) * scale_y
        return expandedPath(rdw: 0, ldw: 0, width: keyWidth).fill(color).frame(width: keyWidth, height: height)
    }

    static func scaleToVariationsSize(keyWidth: CGFloat, scale_y: CGFloat, variationsCount: Int, color: Color, direction: VariationsViewDirection) -> some View {
        let keyViewSize = Design.shared.keyViewSize
        let height = (keyViewSize.height*2 + Design.shared.verticalSpacing) * scale_y
        let dw = (keyViewSize.width * CGFloat(variationsCount - 1) + Design.shared.horizontalSpacing * CGFloat(variationsCount-1))*109/keyViewSize.width
        switch direction{
        case .center:
            return expandedPath(rdw: dw/2, ldw: dw/2, width: keyWidth).fill(color).frame(width: keyWidth, height: height)
        case .right:
            return expandedPath(rdw: dw, ldw: 0, width: keyWidth).fill(color).frame(width: keyWidth, height: height)
        case .left:
            return expandedPath(rdw: 0, ldw: dw, width: keyWidth).fill(color).frame(width: keyWidth, height: height)
        }
    }
}
