//
//  RomanAaKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//
import Foundation
import SwiftUI

struct RomanAaKeyModel: RomanKeyModelProtocol, AaKeyModelProtocol{
    init(){}

    static var shared = RomanAaKeyModel()
    var variableSection = RomanKeyModelVariableSection()
    var keySize: CGSize {
        return CGSize(width: Store.shared.design.romanScaledKeyWidth(normal: scale.normalCount, for: scale.forCount), height: Store.shared.design.keyViewSize.height)
    }
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    private let scale: (normalCount: Int, forCount: Int) = (1, 1)

    var pressActions: [ActionType] {
        switch variableSection.aAKeyState{
        case .normal:
            return [.changeCharacterType]
        case .capslock:
            return [.changeCapsLockState(state: .normal)]
        }
    }

    var longPressActions: [KeyLongPressActionType] {
        switch variableSection.aAKeyState{
        case .normal:
            return [.changeCapsLockState(state: .capslock)]
        case .capslock:
            return []
        }
    }

    func getLabel() -> KeyLabel {
        switch variableSection.aAKeyState{
        case .normal:
            return KeyLabel(.image("textformat.alt"), width: keySize.width)
        case .capslock:
            return KeyLabel(.image("capslock.fill"), width: keySize.width)
        }
    }

    var backGroundColorWhenUnpressed: Color {
        return Store.shared.design.colors.specialKeyColor
    }

    func setKeyState(new state: AaKeyState){
        self.variableSection.aAKeyState = state
    }

    func sound() {
        SoundTools.tabOrOtherKey()
    }

}
