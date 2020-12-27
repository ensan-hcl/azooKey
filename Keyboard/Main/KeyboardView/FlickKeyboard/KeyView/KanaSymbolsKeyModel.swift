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
        Store.shared.userSetting.kanaSymbolsFlickSetting.actions
    }
    var longPressActions: [KeyLongPressActionType] = []
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()

    var labelType: KeyLabelType {
        Store.shared.userSetting.kanaSymbolsFlickSetting.labelType
    }
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        Store.shared.userSetting.kanaSymbolsFlickSetting.flick
    }

    var suggestModel: SuggestModel = SuggestModel(keyType: .kanaSymbols)


    private init(){}

    var label: KeyLabel {
        return KeyLabel(self.labelType, width: keySize.width)
    }

    func sound() {
        Sound.click()
    }
}
