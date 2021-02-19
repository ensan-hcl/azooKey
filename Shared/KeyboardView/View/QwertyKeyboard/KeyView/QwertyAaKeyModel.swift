//
//  QwertyAaKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//
import Foundation
import SwiftUI

struct QwertyAaKeyModel: QwertyKeyModelProtocol{
    static var shared = QwertyAaKeyModel()

    var variableSection = QwertyKeyModelVariableSection()
    let keySizeType: QwertyKeySizeType = .normal(of: 1, for: 1)
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    var pressActions: [ActionType] {
        switch VariableStates.shared.aAKeyState{
        case .normal:
            return [.changeCharacterType]
        case .capslock:
            return [.changeCapsLockState(state: .normal)]
        }
    }

    var longPressActions: [KeyLongPressActionType] {
        switch VariableStates.shared.aAKeyState{
        case .normal:
            return [.doOnce(.changeCapsLockState(state: .capslock))]
        case .capslock:
            return [.doOnce(.changeCapsLockState(state: .normal))]
        }
    }

    func label(width: CGFloat, states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel {
        switch states.aAKeyState{
        case .normal:
            return KeyLabel(.image("textformat.alt"), width: width, theme: theme, textColor: color)
        case .capslock:
            return KeyLabel(.image("capslock.fill"), width: width, theme: theme, textColor: color)
        }
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }

    func sound() {
        Sound.tabOrOtherKey()
    }

}
