//
//  SimpleKeyModel.swift
//  azooKey
//
//  Created by ensan on 2021/02/19.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

enum SimpleUnpressedKeyColorType: UInt8 {
    case normal
    case special
    case enter
    case selected
    case unimportant

    func color(states: VariableStates, theme: ThemeData) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .special:
            return theme.specialKeyFillColor.color
        case .selected:
            return theme.pushedKeyFillColor.color
        case .unimportant:
            return Color(white: 0, opacity: 0.001)
        case .enter:
            switch states.enterKeyState {
            case .complete, .edit:
                return theme.specialKeyFillColor.color
            case let .return(type):
                switch type {
                case .default:
                    return theme.specialKeyFillColor.color
                default:
                    if theme == .default(layout: states.tabManager.tab.existential.layout) {
                        return Design.colors.specialEnterKeyColor
                    } else {
                        return theme.specialKeyFillColor.color
                    }
                }
            }
        }
    }
}

protocol SimpleKeyModelProtocol {
    var longPressActions: LongpressActionType {get}
    var unpressedKeyColorType: SimpleUnpressedKeyColorType {get}
    func pressActions(variableStates: VariableStates) -> [ActionType]
    func feedback(variableStates: VariableStates)
    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    /// `pressActions`とは別に、押された際に発火する操作
    /// - note: タブ固有の事情で実行しなければならないような処理に利用すること
    func additionalOnPress(variableStates: VariableStates)
}

extension SimpleKeyModelProtocol {
    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }

    func additionalOnPress(variableStates: VariableStates) {}
}

struct SimpleKeyModel: SimpleKeyModelProtocol {
    init(keyLabelType: KeyLabelType, unpressedKeyColorType: SimpleUnpressedKeyColorType, pressActions: [ActionType], longPressActions: LongpressActionType = .none) {
        self.keyLabelType = keyLabelType
        self.unpressedKeyColorType = unpressedKeyColorType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
    }

    let unpressedKeyColorType: SimpleUnpressedKeyColorType
    let keyLabelType: KeyLabelType
    private let pressActions: [ActionType]
    let longPressActions: LongpressActionType

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        KeyLabel(self.keyLabelType, width: width)
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        pressActions
    }

    func feedback(variableStates: VariableStates) {
        self.pressActions.first?.feedback(variableStates: variableStates)
    }

}

struct SimpleEnterKeyModel: SimpleKeyModelProtocol {
    func pressActions(variableStates: VariableStates) -> [ActionType] {
        switch variableStates.enterKeyState {
        case .complete:
            return [.enter]
        case .return:
            return [.input("\n")]
        case .edit:
            return [.deselectAndUseAsInputting]
        }
    }

    let longPressActions: LongpressActionType = .none
    let unpressedKeyColorType: SimpleUnpressedKeyColorType = .enter
    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width)
    }

    func feedback(variableStates: VariableStates) {
        switch variableStates.enterKeyState {
        case .complete, .edit:
            KeyboardFeedback.tabOrOtherKey()
        case .return:
            KeyboardFeedback.click()
        }
    }
}

struct SimpleChangeKeyboardKeyModel: SimpleKeyModelProtocol {
    func pressActions(variableStates: VariableStates) -> [ActionType] {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return []
        } else {
            return [.setCursorBar(.toggle)]
        }
    }
    let unpressedKeyColorType: SimpleUnpressedKeyColorType = .special
    let longPressActions: LongpressActionType = .none

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return KeyLabel(.changeKeyboard, width: width)
        } else {
            return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: width)
        }
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback.tabOrOtherKey()
    }
}
