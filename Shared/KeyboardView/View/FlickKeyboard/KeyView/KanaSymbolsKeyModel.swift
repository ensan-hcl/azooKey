//
//  KanaSymbolsKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
struct KanaSymbolsKeyModel: FlickKeyModelProtocol{
    let needSuggestView: Bool = true

    static let shared = KanaSymbolsKeyModel()

    var pressActions: [ActionType] {
        SettingData.shared.kanaSymbolsFlickSetting.actions
    }
    var longPressActions: [KeyLongPressActionType] = []
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()

    var labelType: KeyLabelType {
        SettingData.shared.kanaSymbolsFlickSetting.labelType
    }
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        SettingData.shared.kanaSymbolsFlickSetting.flick
    }

    var suggestModel: SuggestModel = SuggestModel(keyType: .kanaSymbols)


    private init(){}

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func sound() {
        Sound.click()
    }
}
