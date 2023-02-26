//
//  QwertySpaceKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertySpaceKeyModel: QwertyKeyModelProtocol {

    let pressActions: [ActionType] = [.input(" ")]
    var longPressActions: LongpressActionType = .init(start: [.setCursorBar(.toggle)])

    let needSuggestView: Bool = false
    let variationsModel = VariationsModel([])
    let keySizeType: QwertyKeySizeType = .space
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .normal

    init() {}

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch states.keyboardLanguage {
        case .el_GR:
            return KeyLabel(.text("διάστημα"), width: width, textSize: .small, textColor: color)
        case .en_US:
            return KeyLabel(.text("space"), width: width, textSize: .small, textColor: color)
        case .ja_JP, .none:
            return KeyLabel(.text("空白"), width: width, textSize: .small, textColor: color)
        }
    }

    func feedback() {
        KeyboardFeedback.click()
    }
}
