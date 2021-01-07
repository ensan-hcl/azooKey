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
    private let rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)
    
    var keySize: CGSize {
        return CGSize(
            width: Design.shared.qwertyFunctionalKeyWidth(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space),
            height: Design.shared.keyViewSize.height
        )
    }
    
    var backGroundColorWhenUnpressed: Color {
        return Design.shared.colors.specialKeyColor
    }
    
    init(labelType: KeyLabelType, rowInfo: (normal: Int, functional: Int, space: Int, enter: Int), pressActions: [ActionType], longPressActions: [KeyLongPressActionType] = [], needSuggestView: Bool = false){
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.needSuggestView = needSuggestView
        self.rowInfo = rowInfo
    }

    func getLabel() -> KeyLabel {
        return KeyLabel(self.labelType, width: self.keySize.width)
    }

    func sound() {
        self.pressActions.first?.sound()
    }

}
