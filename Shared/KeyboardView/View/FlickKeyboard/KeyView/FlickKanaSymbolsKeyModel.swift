//
//  KanaSymbolsKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
struct FlickKanaSymbolsKeyModel: FlickKeyModelProtocol {
    let needSuggestView: Bool = true

    static let shared = FlickKanaSymbolsKeyModel()
    @KeyboardSetting(.kanaSymbolsFlickCustomKey) private var customKey

    var pressActions: [ActionType] {
        customKey.compiled().actions
    }
    var longPressActions: LongpressActionType {
        customKey.compiled().longpressActions
    }
    var labelType: KeyLabelType {
        customKey.compiled().labelType
    }
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        customKey.compiled().flick
    }

    var suggestModel: SuggestModel = SuggestModel(keyType: .custom(.kanaSymbols))

    private init() {}

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func sound() {
        Sound.click()
    }
}
