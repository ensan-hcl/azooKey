//
//  FlickAaKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/12/11.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import SwiftUI

struct FlickAaKeyModel: FlickKeyModelProtocol {
    let needSuggestView: Bool = true

    static let shared = FlickAaKeyModel()

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        if variableStates.boolStates.isCapsLocked {
            return [.setBoolState(VariableStates.BoolStates.isCapsLockedKey, .off)]
        } else {
            return [.changeCharacterType]
        }
    }

    let longPressActions: LongpressActionType = .none
    func flickKeys(variableStates: VariableStates) -> [CustardKit.FlickDirection: FlickedKeyModel] {
        if variableStates.boolStates.isCapsLocked {
            return [:]
        } else {
            return [
                .top: FlickedKeyModel(
                    labelType: .image("capslock"),
                    pressActions: [.setBoolState(VariableStates.BoolStates.isCapsLockedKey, .on)]
                )
            ]
        }
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        if states.boolStates.isCapsLocked {
            return KeyLabel(.image("capslock.fill"), width: width)
        } else {
            return KeyLabel(.text("a/A"), width: width)
        }
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback.tabOrOtherKey()
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        if states.boolStates.isCapsLocked {
            return theme.specialKeyFillColor.color
        } else {
            return theme.normalKeyFillColor.color
        }
    }
}
