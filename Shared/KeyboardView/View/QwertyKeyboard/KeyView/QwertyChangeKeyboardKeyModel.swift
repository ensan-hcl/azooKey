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

    var pressActions: [ActionType]{
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return []
        case false:
            switch VariableStates.shared.tabManager.currentTab.existential{
            case .qwerty_hira:
                return [.moveTab(.existential(.qwerty_symbols))]
            case .qwerty_abc:
                return [.moveTab(.existential(.qwerty_symbols))]
            case .qwerty_number:
                return [.moveTab(.user_dependent(.english))]
            case .qwerty_symbols:
                return [.moveTab(.user_dependent(.english))]
            default:
                return [.moveTab(.existential(.qwerty_symbols))]
            }
        }

    }
    let longPressActions: [LongPressActionType] = []
    ///暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(keySizeType: QwertyKeySizeType){
        self.keySizeType = keySizeType
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: width, textColor: color)
        case false:
            switch states.tabManager.currentTab.existential{
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
