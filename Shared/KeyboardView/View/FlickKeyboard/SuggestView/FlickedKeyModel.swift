//
//  FlickedView.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

extension FlickDirection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .left:
            return "左"
        case .top:
            return "上"
        case .right:
            return "右"
        case .bottom:
            return "下"
        }
    }
}

struct FlickedKeyModel {
    static let zero: FlickedKeyModel = FlickedKeyModel(labelType: .text(""), pressActions: [])
    let labelType: KeyLabelType
    let pressActions: [ActionType]
    let longPressActions: LongpressActionType

    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: LongpressActionType = .none) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
    }

    func getSuggestView(size: CGSize, isHidden: Bool, isPointed: Bool = false, theme: ThemeData) -> some View {
        var pointedColor: Color {
            theme != .default ? .white : .systemGray4
        }
        var unpointedColor: Color {
            theme != .default ? .white : .systemGray5
        }

        let color = isPointed ? pointedColor : unpointedColor
        return RoundedRectangle(cornerRadius: 5.0)
            .strokeAndFill(fillContent: color, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
            .frame(width: size.width, height: size.height)
            .overlay(self.label(width: size.width, theme: theme))
            .allowsHitTesting(false)
            .opacity(isHidden ? 0:1)
    }

    func label(width: CGFloat, theme: ThemeData) -> some View {
        if theme != .default {
            return KeyLabel(self.labelType, width: width, textColor: .black)
        }
        return KeyLabel(self.labelType, width: width)
    }
}
