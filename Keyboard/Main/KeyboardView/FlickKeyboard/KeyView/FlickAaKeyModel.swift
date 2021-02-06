//
//  FlickAaKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct FlickAaKeyModel: FlickKeyModelProtocol, AaKeyModelProtocol{
    let needSuggestView: Bool = true

    static let shared = FlickAaKeyModel()

    var pressActions: [ActionType] {
        switch VariableStates.shared.aAKeyState{
        case .normal:
            return [.changeCharacterType]
        case .capslock:
            return [.changeCapsLockState(state: .normal)]
        }
    }

    var longPressActions: [KeyLongPressActionType] = []
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        switch VariableStates.shared.aAKeyState{
        case .normal:
            return [
                .top: FlickedKeyModel(labelType: .image("capslock"), pressActions: [.changeCapsLockState(state: .capslock)])
            ]
        case .capslock:
            return [
                :
            ]
        }
    }

    var suggestModel: SuggestModel = SuggestModel([:], keyType: .aA)

    func label(states: VariableStates) -> KeyLabel {
        switch states.aAKeyState{
        case .normal:
            return KeyLabel(.text("a/A"), width: keySize.width)
        case .capslock:
            return KeyLabel(.image("capslock.fill"), width: keySize.width)
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }

    func backGroundColorWhenUnPressed(states: VariableStates) -> Color {
        switch states.aAKeyState{
        case .normal:
            return Design.shared.colors.normalKeyColor
        case .capslock:
            return Design.shared.colors.specialKeyColor
        }
    }

    func setKeyState(new state: AaKeyState) {
        VariableStates.shared.aAKeyState = state
    }
}
