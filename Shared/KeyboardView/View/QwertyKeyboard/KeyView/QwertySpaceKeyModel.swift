//
//  QwertySpaceKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertySpaceKeyModel: QwertyKeyModelProtocol{
    var variableSection = QwertyKeyModelVariableSection()
    
    let pressActions: [ActionType] = [.input(" ")]
    var longPressActions: [KeyLongPressActionType] = [.toggleShowMoveCursorView]

    let needSuggestView: Bool = false
    let variationsModel = VariationsModel([])
    var keySize: CGSize {
        return CGSize(width: Design.shared.qwertySpaceKeyWidth, height: Design.shared.keyViewSize.height)
    }
    init(){}

    func label(states: VariableStates, color: Color? = nil) -> KeyLabel {
        let width = self.keySize.width
        switch states.keyboardLanguage{
        case .english:
            return KeyLabel(.text("space"), width: width, textSize: .small, textColor: color)
        case .japanese:
            return KeyLabel(.text("空白"), width: width, textSize: .small, textColor: color)
        }
    }

    func sound() {
        Sound.click()
    }
}
