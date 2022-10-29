//
//  QwertyFunctionalKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyChangeKeyboardKeyModel: QwertyKeyModelProtocol {

    enum FallBackType {
        case tabBar
        case secondTab(secondLanguage: KeyboardLanguage)
    }

    var pressActions: [ActionType] {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return []
        }
        switch self.fallBackType {
        case let .secondTab(secondLanguage: language):
            let targetTab: Tab = {
                switch language {
                case .en_US:
                    return .user_dependent(.english)
                case .ja_JP:
                    return .user_dependent(.japanese)
                case .none, .el_GR:
                    return .user_dependent(.japanese)
                }
            }()
            switch VariableStates.shared.tabManager.tab.existential {
            case .qwerty_hira:
                return [.moveTab(.existential(.qwerty_symbols))]
            case .qwerty_abc:
                return [.moveTab(.existential(.qwerty_symbols))]
            case .qwerty_number:
                return [.moveTab(targetTab)]
            case .qwerty_symbols:
                return [.moveTab(targetTab)]
            default:
                return [.toggleMoveCursorBar]
            }
        case .tabBar:
            return [.toggleTabBar]
        }
    }
    let fallBackType: FallBackType

    let longPressActions: LongpressActionType = .none
    /// 暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(keySizeType: QwertyKeySizeType, fallBackType: FallBackType) {
        self.keySizeType = keySizeType
        self.fallBackType = fallBackType
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        if SemiStaticStates.shared.needsInputModeSwitchKey {
            return KeyLabel(.changeKeyboard, width: width, textColor: color)
        }
        switch self.fallBackType {
        case let .secondTab(secondLanguage: language):
            switch states.tabManager.tab.existential {
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

    func sound() {
        Sound.tabOrOtherKey()
    }
}
