//
//  QwertyAaKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//
import Foundation
import SwiftUI

struct QwertyAaKeyModel: QwertyKeyModelProtocol {
    static var shared = QwertyAaKeyModel()

    let keySizeType: QwertyKeySizeType = .normal(of: 1, for: 1)
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    var pressActions: [ActionType] {
        if VariableStates.shared.boolStates.isCapsLocked {
            return [.setCapsLockState(.off)]
        } else {
            return [.changeCharacterType]
        }
    }

    var longPressActions: LongpressActionType {
        return .init(start: [.setCapsLockState(.toggle)])
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        if states.boolStates.isCapsLocked {
            return KeyLabel(.image("capslock.fill"), width: width, textColor: color)
        } else {
            return KeyLabel(.image("textformat.alt"), width: width, textColor: color)
        }
    }

    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    func sound() {
        Sound.tabOrOtherKey()
    }

}
