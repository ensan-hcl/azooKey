//
//  FlickAaKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct FlickAaKeyModel: FlickKeyModelProtocol{
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

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        switch states.aAKeyState{
        case .normal:
            return KeyLabel(.text("a/A"), width: width)
        case .capslock:
            return KeyLabel(.image("capslock.fill"), width: width)
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        switch states.aAKeyState{
        case .normal:
            return theme.normalKeyFillColor.color
        case .capslock:
            return theme.specialKeyFillColor.color
        }
    }
}
