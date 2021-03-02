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
    
    let pressActions: [ActionType] = [.input(" ")]
    var longPressActions: [LongPressActionType] = [.doOnce(.toggleShowMoveCursorView)]

    let needSuggestView: Bool = false
    let variationsModel = VariationsModel([])
    let keySizeType: QwertyKeySizeType = .space(.default)
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .normal

    init(){}

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch states.keyboardLanguage{
        case .greek:
            return KeyLabel(.text("διάστημα"), width: width, textSize: .small, textColor: color)
        case .english:
            return KeyLabel(.text("space"), width: width, textSize: .small, textColor: color)
        case .japanese, .none:
            return KeyLabel(.text("空白"), width: width, textSize: .small, textColor: color)
        }
    }

    func sound() {
        Sound.click()
    }
}
