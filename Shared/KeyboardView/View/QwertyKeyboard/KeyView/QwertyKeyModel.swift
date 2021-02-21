//
//  QwertyKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyKeyModel: QwertyKeyModelProtocol{
    var variableSection = QwertyKeyModelVariableSection()
    
    let pressActions: [ActionType]
    var longPressActions: [KeyLongPressActionType]

    let labelType: KeyLabelType
    let needSuggestView: Bool
    let variationsModel: VariationsModel

    let keySizeType: QwertyKeySizeType

    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: [KeyLongPressActionType] = [], variationsModel: VariationsModel = VariationsModel([]),  needSuggestView: Bool = true, for scale: (normalCount: Int, forCount: Int) = (1, 1)){
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.needSuggestView = needSuggestView
        self.variationsModel = variationsModel
        self.keySizeType = .normal(of: scale.normalCount, for: scale.forCount)
    }

    func label(width: CGFloat, states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel {
        if states.aAKeyState == .capslock, states.keyboardLanguage == .english, case let .text(text) = self.labelType{
            return KeyLabel(.text(text.uppercased()), width: width, theme: theme, textColor: color)
        }
        return KeyLabel(self.labelType, width: width, theme: theme, textColor: color)
    }

    func sound(){
        self.pressActions.first?.sound()
    }
}
