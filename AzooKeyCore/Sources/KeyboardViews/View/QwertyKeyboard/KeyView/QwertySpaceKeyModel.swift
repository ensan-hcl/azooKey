//
//  QwertySpaceKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertySpaceKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {
    var longPressActions: LongpressActionType = .init(start: [.setCursorBar(.toggle)])

    let needSuggestView: Bool = false
    let variationsModel = VariationsModel([])
    let keySizeType: QwertyKeySizeType = .space
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .normal

    init() {}

    func label<E: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<E> {
        switch states.keyboardLanguage {
        case .el_GR:
            return KeyLabel(.text("διάστημα"), width: width, textSize: .small, textColor: color)
        case .en_US:
            return KeyLabel(.text("space"), width: width, textSize: .small, textColor: color)
        case .ja_JP, .none:
            return KeyLabel(.text("空白"), width: width, textSize: .small, textColor: color)
        }
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        [.input(" ")]
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.click()
    }
}
