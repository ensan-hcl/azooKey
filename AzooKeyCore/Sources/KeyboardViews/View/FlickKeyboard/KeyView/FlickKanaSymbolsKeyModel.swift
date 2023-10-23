//
//  KanaSymbolsKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/12/27.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickKanaSymbolsKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: FlickKeyModelProtocol {
    let needSuggestView: Bool = true

    static var shared: Self { FlickKanaSymbolsKeyModel() }
    @MainActor private var customKey: KeyFlickSetting {
        Extension.SettingProvider.kanaSymbolsFlickCustomKey
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        customKey.compiled().actions
    }
    func longPressActions(variableStates _: VariableStates) -> LongpressActionType {
        customKey.compiled().longpressActions
    }
    @MainActor var labelType: KeyLabelType {
        customKey.compiled().labelType
    }
    func flickKeys(variableStates: VariableStates) -> [CustardKit.FlickDirection: FlickedKeyModel] {
        customKey.compiled().flick
    }

    private init() {}

    func label<E: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates) -> KeyLabel<E> {
        KeyLabel(self.labelType, width: width)
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback<Extension>.click()
    }
}
