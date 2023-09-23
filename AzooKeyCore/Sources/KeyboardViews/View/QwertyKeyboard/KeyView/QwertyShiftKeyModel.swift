//
//  QwertyShiftKeyModel.swift
//  
//
//  Created by ensan on 2023/08/11.
//

import SwiftUI

struct QwertyShiftKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {
    static var shared: Self { QwertyShiftKeyModel() }

    let keySizeType: QwertyKeySizeType = .normal(of: 1, for: 1)
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        if variableStates.boolStates.isCapsLocked {
            return [.setBoolState(VariableStates.BoolStates.isCapsLockedKey, .off)]
        } else if variableStates.boolStates.isShifted {
            return [.setBoolState(VariableStates.BoolStates.isShiftedKey, .off)]
        } else {
            return [.setBoolState(VariableStates.BoolStates.isShiftedKey, .on)]
        }
    }

    var longPressActions: LongpressActionType {
        .init(start: [.setBoolState(VariableStates.BoolStates.isCapsLockedKey, .toggle)])
    }

    func doublePressActions(variableStates: VariableStates) -> [ActionType] {
        if variableStates.boolStates.isCapsLocked {
            return []
        } else {
            return [.setBoolState(VariableStates.BoolStates.isCapsLockedKey, .on)]
        }
    }

    func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<Extension> {
        if states.boolStates.isCapsLocked {
            return KeyLabel(.image("capslock.fill"), width: width, textColor: color)
        } else if states.boolStates.isShifted {
            return KeyLabel(.image("shift.fill"), width: width, textColor: color)
        } else {
            return KeyLabel(.image("shift"), width: width, textColor: color)
        }
    }

    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.tabOrOtherKey()
    }

}
