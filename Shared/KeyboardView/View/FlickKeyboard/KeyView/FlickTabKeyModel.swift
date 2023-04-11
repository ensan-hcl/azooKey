//
//  TabKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/04/12.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickTabKeyModel: FlickKeyModelProtocol {
    private let data: KeyFlickSetting.SettingData
    let needSuggestView: Bool = true

    @MainActor static func hiraTabKeyModel() -> Self { FlickTabKeyModel(tab: .user_dependent(.japanese), key: .hiraTab) }
    @MainActor static func abcTabKeyModel() -> Self {  FlickTabKeyModel(tab: .user_dependent(.english), key: .abcTab) }
    @MainActor static func numberTabKeyModel() -> Self {  FlickTabKeyModel(tab: .existential(.flick_numbersymbols), key: .symbolsTab) }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        self.data.actions
    }
    var longPressActions: LongpressActionType {
        self.data.longpressActions
    }

    func flickKeys(variableStates: VariableStates) -> [FlickDirection: FlickedKeyModel] {
        self.data.flick
    }

    private var tab: Tab

    @MainActor private init(tab: Tab, key: CustomizableFlickKey) {
        self.data = key.get()
        self.tab = tab
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.data.labelType, width: width)
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        if states.tabManager.isCurrentTab(tab: tab) {
            return theme.pushedKeyFillColor.color
        }
        return theme.specialKeyFillColor.color
    }

    func feedback(variableStates: VariableStates) {
        KeyboardFeedback.tabOrOtherKey()
    }
}
