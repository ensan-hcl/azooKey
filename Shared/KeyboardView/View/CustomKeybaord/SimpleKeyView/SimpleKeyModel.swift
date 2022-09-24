//
//  SimpleKeyModel.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/19.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum SimpleUnpressedKeyColorType {
    case normal
    case special
    case enter
    case selected
    func color(states: VariableStates, theme: ThemeData) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .special:
            return theme.specialKeyFillColor.color
        case .selected:
            return theme.pushedKeyFillColor.color
        case .enter:
            switch states.enterKeyState {
            case .complete, .edit:
                return theme.specialKeyFillColor.color
            case let .return(type):
                switch type {
                case .default:
                    return theme.specialKeyFillColor.color
                default:
                    if theme == .default {
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
    var pressActions: [ActionType] {get}
    var longPressActions: LongpressActionType {get}
    var unpressedKeyColorType: SimpleUnpressedKeyColorType {get}
    func press()
    func longPressReserve()
    func longPressEnd()
    func sound()
    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
}

extension SimpleKeyModelProtocol {
    func press() {
        VariableStates.shared.action.registerActions(self.pressActions)
    }

    func longPressReserve() {
        VariableStates.shared.action.reserveLongPressAction(longPressActions)
    }

    func longPressEnd() {
        VariableStates.shared.action.registerLongPressActionEnd(longPressActions)
    }

    func sound() {
        self.pressActions.first?.sound()
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }
}

struct SimpleKeyModel: SimpleKeyModelProtocol {
    init(keyType: SimpleKeyColorType, keyLabelType: KeyLabelType, unpressedKeyColorType: SimpleUnpressedKeyColorType, pressActions: [ActionType], longPressActions: LongpressActionType = .none) {
        self.keyType = keyType
        self.keyLabelType = keyLabelType
        self.unpressedKeyColorType = unpressedKeyColorType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
    }

    enum SimpleKeyColorType {
        case normal
        case functional
    }

    let keyType: SimpleKeyColorType
    let unpressedKeyColorType: SimpleUnpressedKeyColorType
    let keyLabelType: KeyLabelType
    let pressActions: [ActionType]
    let longPressActions: LongpressActionType

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        KeyLabel(self.keyLabelType, width: width)
    }
}

struct SimpleEnterKeyModel: SimpleKeyModelProtocol {

    var pressActions: [ActionType] {
        switch VariableStates.shared.enterKeyState {
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
}

struct SimpleChangeKeyboardKeyModel: SimpleKeyModelProtocol {
    var pressActions: [ActionType] {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return []
        } else {
            return [.toggleShowMoveCursorView]
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
}
