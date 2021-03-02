//
//  TabKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickTabKeyModel: FlickKeyModelProtocol{
    private let setting: Setting
    let needSuggestView: Bool = true
    
    static let hiraTabKeyModel = FlickTabKeyModel(tab: .user_dependent(.japanese), setting: .hiraTabKeyFlick)
    static let abcTabKeyModel = FlickTabKeyModel(tab: .user_dependent(.english), setting: .abcTabKeyFlick)
    static let numberTabKeyModel = FlickTabKeyModel(tab: .existential(.flick_numbersymbols), setting: .symbolsTabKeyFlick)

    var pressActions: [ActionType] {
        SettingData.shared.flickCustomKeySetting(for: setting).actions
    }
    var longPressActions: [LongPressActionType] {
        SettingData.shared.flickCustomKeySetting(for: setting).longpressActions
    }
    var labelType: KeyLabelType {
        SettingData.shared.flickCustomKeySetting(for: setting).labelType
    }
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        SettingData.shared.flickCustomKeySetting(for: setting).flick
    }

    let suggestModel: SuggestModel
    var tab: Tab

    private init(tab: Tab, setting: Setting){
        self.setting = setting
        self.tab = tab
        self.suggestModel = SuggestModel([:], keyType: .custom(setting))
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        if states.tabManager.isCurrentTab(tab: tab){
            return theme.pushedKeyFillColor.color
        }
        return theme.specialKeyFillColor.color
    }
    
    func sound() {
        Sound.tabOrOtherKey()
    }
}
