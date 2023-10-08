//
//  QwertyFunctionalKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import enum CustardKit.TabData
import enum KanaKanjiConverterModule.KeyboardLanguage

struct QwertyChangeKeyboardKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {

    enum FallBackType {
        case tabBar
        case secondTab(secondLanguage: KeyboardLanguage)
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return []
        }
        switch self.fallBackType {
        case let .secondTab(secondLanguage: language):
            let targetTab: TabData = {
                switch language {
                case .en_US:
                    return .system(.user_english)
                case .ja_JP:
                    return .system(.user_japanese)
                case .none, .el_GR:
                    return.system(.user_japanese)
                }
            }()
            switch variableStates.tabManager.existentialTab() {
            case .qwerty_hira:
                return [.moveTab(.system(.qwerty_symbols))]
            case .qwerty_abc:
                return [.moveTab(.system(.qwerty_symbols))]
            case .qwerty_number:
                return [.moveTab(targetTab)]
            case .qwerty_symbols:
                return [.moveTab(targetTab)]
            default:
                return [.setCursorBar(.toggle)]
            }
        case .tabBar:
            return [.setTabBar(.toggle)]
        }
    }
    let fallBackType: FallBackType

    func longPressActions(variableStates _: VariableStates) -> LongpressActionType {
        .none
    }

    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(keySizeType: QwertyKeySizeType, fallBackType: FallBackType) {
        self.keySizeType = keySizeType
        self.fallBackType = fallBackType
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<Extension> {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return KeyLabel(.changeKeyboard, width: width, textColor: color)
        }
        switch self.fallBackType {
        case let .secondTab(secondLanguage: language):
            switch states.tabManager.existentialTab() {
            case .qwerty_hira:
                return KeyLabel(.text("#+="), width: width, textColor: color)
            case .qwerty_abc:
                return KeyLabel(.text("#+="), width: width, textColor: color)
            case .qwerty_number:
                return KeyLabel(.text(language.symbol), width: width, textColor: color)
            case .qwerty_symbols:
                return KeyLabel(.text(language.symbol), width: width, textColor: color)
            default:
                return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: width)
            }
        case .tabBar:
            return KeyLabel(.image("list.bullet"), width: width, textColor: color)
        }
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.tabOrOtherKey()
    }
}
