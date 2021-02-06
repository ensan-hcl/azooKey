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
    var keySize: CGSize {
        return CGSize(width: Design.shared.qwertyScaledKeyWidth(normal: scale.normalCount, for: scale.forCount), height: Design.shared.keyViewSize.height)
    }
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    private let scale: (normalCount: Int, forCount: Int) = (1, 1)

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
            return [.changeCapsLockState(state: .capslock)]
        case .capslock:
            return []
        }
    }

    func label(states: VariableStates) -> KeyLabel {
        switch states.aAKeyState{
        case .normal:
            return KeyLabel(.image("textformat.alt"), width: keySize.width)
        case .capslock:
            return KeyLabel(.image("capslock.fill"), width: keySize.width)
        }
    }

    func backGroundColorWhenUnpressed(states: VariableStates) -> Color {
        return Design.shared.colors.specialKeyColor
    }

    func sound() {
        Sound.tabOrOtherKey()
    }

}
