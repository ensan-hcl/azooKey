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
    private let rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)

    var keySize: CGSize {
        return CGSize(
            width: Design.shared.qwertyFunctionalKeyWidth(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space),
            height: Design.shared.keyViewSize.height
        )
    }

    func backGroundColorWhenUnpressed(states: VariableStates) -> Color {
        Design.colors.specialKeyColor
    }

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)){
        self.rowInfo = rowInfo
    }

    func label(states: VariableStates) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: self.keySize.width)
        case false:
            switch states.tabState{
            case .hira:
                return KeyLabel(.text("#+="), width: self.keySize.width)
            case .abc:
                return KeyLabel(.text("#+="), width: self.keySize.width)
            case .number:
                return KeyLabel(.text("A"), width: self.keySize.width)
            case let .other(string) where string == "symbols":
                return KeyLabel(.text("A"), width: self.keySize.width)
            default:
                return KeyLabel(.text("#+="), width: self.keySize.width)
            }
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}