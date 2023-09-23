//
//  EnterKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/04/12.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import KeyboardThemes
import SwiftUI

struct FlickEnterKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: FlickKeyModelProtocol {
    static var shared: Self { FlickEnterKeyModel() }
    let needSuggestView = false

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        switch variableStates.enterKeyState {
        case .complete:
            return [.enter]
        case .return:
            return [.input("\n")]
        }
    }

    var longPressActions: LongpressActionType = .none

    func flickKeys(variableStates: VariableStates) -> [FlickDirection: FlickedKeyModel] {
        [:]
    }

    func label<E: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates) -> KeyLabel<E> {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width)
    }

    func backGroundColorWhenUnpressed<ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(states: VariableStates, theme: ThemeData<ThemeExtension>) -> Color {
        switch states.enterKeyState {
        case .complete:
            return theme.specialKeyFillColor.color
        case let .return(type):
            switch type {
            case .default:
                return theme.specialKeyFillColor.color
            default:
                if theme == ThemeExtension.default(layout: .flick) {
                    return Design.colors.specialEnterKeyColor
                } else {
                    return theme.specialKeyFillColor.color
                }
            }
        }
    }

    func feedback(variableStates: VariableStates) {
        switch variableStates.enterKeyState {
        case .complete:
            KeyboardFeedback<Extension>.tabOrOtherKey()
        case let .return(type):
            switch type {
            case .default:
                KeyboardFeedback<Extension>.click()
            default:
                KeyboardFeedback<Extension>.tabOrOtherKey()
            }
        }
    }
}
