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
        switch VariableStates.shared.aAKeyState {
        case .normal:
            return [.changeCharacterType]
        case .capsLock:
            return [.changeCapsLockState(state: .normal)]
        }
    }

    var longPressActions: LongpressActionType {
        switch VariableStates.shared.aAKeyState {
        case .normal:
            return .init(start: [.changeCapsLockState(state: .capsLock)])
        case .capsLock:
            return .init(start: [.changeCapsLockState(state: .normal)])
        }
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch states.aAKeyState {
        case .normal:
            return KeyLabel(.image("textformat.alt"), width: width, textColor: color)
        case .capsLock:
            return KeyLabel(.image("capslock.fill"), width: width, textColor: color)
        }
    }

    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    func sound() {
        Sound.tabOrOtherKey()
    }

}
