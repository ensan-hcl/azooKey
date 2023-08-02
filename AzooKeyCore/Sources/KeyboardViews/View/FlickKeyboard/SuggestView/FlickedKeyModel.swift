//
//  FlickedView.swift
//  Keyboard
//
//  Created by ensan on 2020/04/11.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import KeyboardThemes
import SwiftUI
import SwiftUIUtils

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

public struct FlickedKeyModel {
    static var zero: Self { FlickedKeyModel(labelType: .text(""), pressActions: []) }
    let labelType: KeyLabelType
    let pressActions: [ActionType]
    let longPressActions: LongpressActionType

    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: LongpressActionType = .none) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
    }

    @MainActor func getSuggestView<Extension: ApplicationSpecificKeyboardViewExtension>(size: CGSize, isHidden: Bool, isPointed: Bool = false, theme: Extension.Theme, extension: Extension.Type) -> some View {
        var pointedColor: Color {
            theme != Extension.ThemeExtension.default(layout: .flick) ? .white : .systemGray4
        }
        var unpointedColor: Color {
            theme != Extension.ThemeExtension.default(layout: .flick) ? .white : .systemGray5
        }

        let color = isPointed ? pointedColor : unpointedColor
        return RoundedRectangle(cornerRadius: 5.0)
            .strokeAndFill(fillContent: color, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
            .frame(width: size.width, height: size.height)
            .overlay(self.label(width: size.width, theme: theme, extension: Extension.self))
            .allowsHitTesting(false)
            .opacity(isHidden ? 0 : 1)
    }

    @MainActor func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, theme: Extension.Theme, extension: Extension.Type) -> some View {
        if theme != Extension.ThemeExtension.default(layout: .flick) {
            return KeyLabel<Extension>(self.labelType, width: width, textColor: .black)
        }
        return KeyLabel<Extension>(self.labelType, width: width)
    }
}
