//
//  QwertyFunctionalKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyChangeKeyboardKeyModel: QwertyKeyModelProtocol{
    var variableSection = QwertyKeyModelVariableSection()

    var pressActions: [ActionType]{
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return []
        case false:
            switch VariableStates.shared.tabManager.currentTab{
            case .qwerty_hira:
                return [.moveTab(.qwerty_symbols)]
            case .qwerty_abc:
                return [.moveTab(.qwerty_symbols)]
            case .qwerty_number:
                return [.moveTab(.user_dependent(.english))]
            case .qwerty_symbols:
                return [.moveTab(.user_dependent(.english))]
            default:
                return [.moveTab(.qwerty_symbols)]
            }
        }

    }
    let longPressActions: [KeyLongPressActionType] = []
    ///暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }

    init(keySizeType: QwertyKeySizeType){
        self.keySizeType = keySizeType
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: width, textColor: color)
        case false:
            switch states.tabManager.currentTab{
            case .qwerty_hira:
                return KeyLabel(.text("#+="), width: width, textColor: color)
            case .qwerty_abc:
                return KeyLabel(.text("#+="), width: width, textColor: color)
            case .qwerty_number:
                return KeyLabel(.text("A"), width: width, textColor: color)
            case .qwerty_symbols:
                return KeyLabel(.text("A"), width: width, textColor: color)
            default:
                return KeyLabel(.text("#+="), width: width, textColor: color)
            }
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
