//
//  QwertyKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyKeyModel: QwertyKeyModelProtocol {

    private let pressActions: [ActionType]
    var longPressActions: LongpressActionType

    let labelType: KeyLabelType
    let needSuggestView: Bool
    let variationsModel: VariationsModel

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType

    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: LongpressActionType = .none, variationsModel: VariationsModel = VariationsModel([]), keyColorType: QwertyUnpressedKeyColorType = .normal, needSuggestView: Bool = true, for scale: (normalCount: Int, forCount: Int) = (1, 1)) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.needSuggestView = needSuggestView
        self.variationsModel = variationsModel
        self.keySizeType = .normal(of: scale.normalCount, for: scale.forCount)
        self.unpressedKeyColorType = keyColorType
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        if states.boolStates.isCapsLocked, states.keyboardLanguage == .en_US, case let .text(text) = self.labelType {
            return KeyLabel(.text(text.uppercased()), width: width, textColor: color)
        }
        return KeyLabel(self.labelType, width: width, textColor: color)
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        self.pressActions
    }

    func feedback(variableStates: VariableStates) {
        self.pressActions.first?.feedback(variableStates: variableStates)
    }

}
