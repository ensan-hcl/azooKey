//
//  SimpleKeyModel.swift
//  azooKey
//
//  Created by ensan on 2021/02/19.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import KeyboardThemes
import SwiftUI

enum SimpleUnpressedKeyColorType: UInt8 {
    case normal
    case special
    case enter
    case selected
    case unimportant

    @MainActor func color<ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(states: VariableStates, theme: ThemeData<ThemeExtension>) -> Color {
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
                    if theme == ThemeExtension.default(layout: states.tabManager.existentialTab().layout) {
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
    associatedtype Extension: ApplicationSpecificKeyboardViewExtension

    var longPressActions: LongpressActionType {get}
    var unpressedKeyColorType: SimpleUnpressedKeyColorType {get}
    @MainActor func pressActions(variableStates: VariableStates) -> [ActionType]
    @MainActor func feedback(variableStates: VariableStates)
    @MainActor func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, theme: Extension.Theme) -> KeyLabel<Extension>
    @MainActor func backGroundColorWhenPressed(theme: Extension.Theme) -> Color
    /// `pressActions`とは別に、押された際に発火する操作
    /// - note: タブ固有の事情で実行しなければならないような処理に利用すること
    @MainActor func additionalOnPress(variableStates: VariableStates)
}

extension SimpleKeyModelProtocol {
    func backGroundColorWhenPressed(theme: ThemeData<some ApplicationSpecificTheme>) -> Color {
        theme.pushedKeyFillColor.color
    }

    func additionalOnPress(variableStates: VariableStates) {}
}

struct SimpleKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: SimpleKeyModelProtocol {
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

    func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, theme: ThemeData<some ApplicationSpecificTheme>) -> KeyLabel<Extension> {
        KeyLabel(self.keyLabelType, width: width)
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        pressActions
    }

    func feedback(variableStates: VariableStates) {
        self.pressActions.first?.feedback(variableStates: variableStates, extension: Extension.self)
    }

}

struct SimpleEnterKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: SimpleKeyModelProtocol {
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
    func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, theme: ThemeData<some ApplicationSpecificTheme>) -> KeyLabel<Extension> {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width)
    }

    func feedback(variableStates: VariableStates) {
        switch variableStates.enterKeyState {
        case .complete, .edit:
            KeyboardFeedback<Extension>.tabOrOtherKey()
        case .return:
            KeyboardFeedback<Extension>.click()
        }
    }
}

struct SimpleChangeKeyboardKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: SimpleKeyModelProtocol {
    func pressActions(variableStates: VariableStates) -> [ActionType] {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return []
        } else {
            return [.setCursorBar(.toggle)]
        }
    }
    let unpressedKeyColorType: SimpleUnpressedKeyColorType = .special
    let longPressActions: LongpressActionType = .none

    func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, theme: ThemeData<some ApplicationSpecificTheme>) -> KeyLabel<Extension> {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return KeyLabel(.changeKeyboard, width: width)
        } else {
            return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: width)
        }
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.tabOrOtherKey()
    }
}
