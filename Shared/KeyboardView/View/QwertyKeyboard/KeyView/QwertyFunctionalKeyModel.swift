//
//  QwertyFunctionalKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyFunctionalKeyModel: QwertyKeyModelProtocol{
    var variableSection = QwertyKeyModelVariableSection()
    
    let pressActions: [ActionType]
    var longPressActions: [KeyLongPressActionType]
    ///暫定
    let variationsModel = VariationsModel([])

    let labelType: KeyLabelType
    let needSuggestView: Bool
    let keySizeType: QwertyKeySizeType

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }
    
    init(labelType: KeyLabelType, rowInfo: (normal: Int, functional: Int, space: Int, enter: Int), pressActions: [ActionType], longPressActions: [KeyLongPressActionType] = [], needSuggestView: Bool = false){
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.needSuggestView = needSuggestView
        self.keySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
    }

    func label(width: CGFloat, states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel {
        KeyLabel(self.labelType, width: width, theme: theme, textColor: color)
    }

    func sound() {
        self.pressActions.first?.sound()
    }

}
