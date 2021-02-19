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

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: width, theme: theme)
        case false:
            return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: width, theme: theme)
        }
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
