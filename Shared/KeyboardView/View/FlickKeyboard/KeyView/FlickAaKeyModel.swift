//
//  FlickAaKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
import CustardKit

struct FlickAaKeyModel: FlickKeyModelProtocol {
    let needSuggestView: Bool = true

    static let shared = FlickAaKeyModel()

    var pressActions: [ActionType] {
        if VariableStates.shared.boolStates.isCapsLocked {
            return [.setCapsLockState(.off)]
        } else {
            return [.changeCharacterType]
        }
    }

    let longPressActions: LongpressActionType = .none
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        if VariableStates.shared.boolStates.isCapsLocked {
            return [:]
        } else {
            return [
                .top: FlickedKeyModel(labelType: .image("capslock"), pressActions: [.setCapsLockState(.on)])
            ]
        }
    }

    var suggestModel: SuggestModel = SuggestModel([:], keyType: .aA)

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        if states.boolStates.isCapsLocked {
            return KeyLabel(.image("capslock.fill"), width: width)
        } else {
            return KeyLabel(.text("a/A"), width: width)
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        if states.boolStates.isCapsLocked {
            return theme.specialKeyFillColor.color
        } else {
            return theme.normalKeyFillColor.color
        }
    }
}
