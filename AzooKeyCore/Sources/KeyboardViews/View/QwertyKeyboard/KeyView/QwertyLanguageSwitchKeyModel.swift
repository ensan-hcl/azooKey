//
//  QwertyLanguageSwitchKeyModel.swift
//  azooKey
//
//  Created by ensan on 2021/03/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import enum KanaKanjiConverterModule.KeyboardLanguage

// symbolタブ、123タブで表示される切り替えボタン
struct QwertySwitchLanguageKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {
    let languages: (KeyboardLanguage, KeyboardLanguage)
    @MainActor func currentTabLanguage(variableStates: VariableStates) -> KeyboardLanguage? {
        variableStates.tabManager.existentialTab().language
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        let target: KeyboardLanguage
        let current = currentTabLanguage(variableStates: variableStates)
        if languages.0 == current {
            target = languages.1
        } else if languages.1 == current {
            target = languages.0
        } else if SemiStaticStates.shared.needsInputModeSwitchKey {
            target = variableStates.keyboardLanguage
        } else {
            target = Extension.SettingProvider.preferredLanguage.first
        }
        switch target {
        case .ja_JP:
            return [.moveTab(.system(.user_japanese))]
        case .en_US:
            return [.moveTab(.system(.user_english))]
        case .none, .el_GR:
            return []
        }
    }

    let longPressActions: LongpressActionType = .none
    /// 暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int), languages: (KeyboardLanguage, KeyboardLanguage)) {
        self.keySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
        self.languages = languages
    }

    func label<E: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<E> {
        let current = currentTabLanguage(variableStates: states)
        if languages.0 == current {
            return KeyLabel(.selectable(languages.0.symbol, languages.1.symbol), width: width, textColor: color)
        } else if languages.1 == current {
            return KeyLabel(.selectable(languages.1.symbol, languages.0.symbol), width: width, textColor: color)
        } else if SemiStaticStates.shared.needsInputModeSwitchKey {
            return KeyLabel(.text(states.keyboardLanguage.symbol), width: width, textColor: color)
        } else {
            return KeyLabel(.text(E.SettingProvider.preferredLanguage.first.symbol), width: width, textColor: color)
        }
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.tabOrOtherKey()
    }
}
