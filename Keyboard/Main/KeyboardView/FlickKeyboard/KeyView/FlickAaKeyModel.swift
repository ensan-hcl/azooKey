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
        switch variableSection.aAKeyState{
        case .normal:
            return [.changeCharacterType]
        case .capslock:
            return [.changeCapsLockState(state: .normal)]
        }
    }

    var longPressActions: [KeyLongPressActionType] = []
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        switch variableSection.aAKeyState{
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

    var label: KeyLabel {
        switch variableSection.aAKeyState{
        case .normal:
            return KeyLabel(.text("a/A"), width: keySize.width)
        case .capslock:
            return KeyLabel(.image("capslock.fill"), width: keySize.width)
        }
    }

    func sound() {
        SoundTools.tabOrOtherKey()
    }

    var backGroundColorWhenUnpressed: Color {
        switch variableSection.aAKeyState{
        case .normal:
            return Design.shared.colors.normalKeyColor
        case .capslock:
            return Design.shared.colors.specialKeyColor
        }
    }

    func setKeyState(new state: AaKeyState) {
        self.variableSection.aAKeyState = state
    }
}
