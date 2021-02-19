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
            switch VariableStates.shared.tabState{
            case .hira:
                return [.moveTab(.other(QwertyAdditionalTabs.symbols.identifier))]
            case .abc:
                return [.moveTab(.other(QwertyAdditionalTabs.symbols.identifier))]
            case .number:
                return [.moveTab(.abc)]
            case let .other(string) where string == QwertyAdditionalTabs.symbols.identifier:
                return [.moveTab(.abc)]
            default:
                return [.moveTab(.other(QwertyAdditionalTabs.symbols.identifier))]
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

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)){
        self.keySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
    }

    func label(width: CGFloat, states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: width, theme: theme, textColor: color)
        case false:
            switch states.tabState{
            case .hira:
                return KeyLabel(.text("#+="), width: width, theme: theme, textColor: color)
            case .abc:
                return KeyLabel(.text("#+="), width: width, theme: theme, textColor: color)
            case .number:
                return KeyLabel(.text("A"), width: width, theme: theme, textColor: color)
            case let .other(string) where string == "symbols":
                return KeyLabel(.text("A"), width: width, theme: theme, textColor: color)
            default:
                return KeyLabel(.text("#+="), width: width, theme: theme, textColor: color)
            }
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
