//
//  EnterKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/04/12.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickEnterKeyModel: FlickKeyModelProtocol {
    static let shared = FlickEnterKeyModel()
    let needSuggestView = false

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

    var longPressActions: LongpressActionType = .none

    func flickKeys(variableStates: VariableStates) -> [FlickDirection: FlickedKeyModel] {
        [:]
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width)
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: AzooKeyTheme) -> Color {
        switch states.enterKeyState {
        case .complete, .edit:
            return theme.specialKeyFillColor.color
        case let .return(type):
            switch type {
            case .default:
                return theme.specialKeyFillColor.color
            default:
                if theme == .default(layout: .flick) {
                    return Design.colors.specialEnterKeyColor
                } else {
                    return theme.specialKeyFillColor.color
                }
            }
        }
    }

    func feedback(variableStates: VariableStates) {
        switch variableStates.enterKeyState {
        case .complete, .edit:
            KeyboardFeedback.tabOrOtherKey()
        case let .return(type):
            switch type {
            case .default:
                KeyboardFeedback.click()
            default:
                KeyboardFeedback.tabOrOtherKey()
            }
        }
    }
}
