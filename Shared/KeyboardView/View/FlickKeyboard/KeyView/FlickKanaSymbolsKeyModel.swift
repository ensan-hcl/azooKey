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

    var pressActions: [ActionType] {
        SettingData.shared.flickCustomKeySetting(for: .kanaSymbolsKeyFlick).actions
    }
    var longPressActions: LongpressActionType {
        SettingData.shared.flickCustomKeySetting(for: .kanaSymbolsKeyFlick).longpressActions
    }
    var labelType: KeyLabelType {
        SettingData.shared.flickCustomKeySetting(for: .kanaSymbolsKeyFlick).labelType
    }
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        SettingData.shared.flickCustomKeySetting(for: .kanaSymbolsKeyFlick).flick
    }

    var suggestModel: SuggestModel = SuggestModel(keyType: .custom(.kanaSymbolsKeyFlick))

    private init() {}

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func sound() {
        Sound.click()
    }
}
