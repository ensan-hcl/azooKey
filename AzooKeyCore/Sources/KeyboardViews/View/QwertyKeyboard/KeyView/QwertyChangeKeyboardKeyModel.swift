//
//  QwertyFunctionalKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import enum CustardKit.TabData
import enum KanaKanjiConverterModule.KeyboardLanguage

struct QwertyChangeKeyboardKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {
    func pressActions(variableStates: VariableStates) -> [ActionType] {
        [] 
    }

    func longPressActions(variableStates _: VariableStates) -> LongpressActionType {
        .none
    }

    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(keySizeType: QwertyKeySizeType) {
        self.keySizeType = keySizeType
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<Extension> {
        KeyLabel(.changeKeyboard, width: width, textColor: color)
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.tabOrOtherKey()
    }
}
