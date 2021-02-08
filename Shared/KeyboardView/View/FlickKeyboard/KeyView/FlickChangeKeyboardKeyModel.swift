//
//  ChangeKeyboardFlickKey.swift
//  Keyboard
//
//  Created by β α on 2020/10/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickChangeKeyboardModel: FlickKeyModelProtocol{
    let needSuggestView: Bool = false

    static let shared = FlickChangeKeyboardModel()

    var pressActions: [ActionType]{
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return []
        case false:
            return [.toggleShowMoveCursorView]
        }
    }
    var longPressActions: [KeyLongPressActionType]{ [] }
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()

    let suggestModel: SuggestModel
    let flickKeys: [FlickDirection: FlickedKeyModel] = [:]

    init(){
        self.suggestModel = SuggestModel([:])
    }

    func label(states: VariableStates) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: self.keySize.width)
        case false:
            return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: self.keySize.width)
        }
    }

    func backGroundColorWhenUnpressed(states: VariableStates) -> Color {
        states.themeManager.theme.specialKeyFillColor.color
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
