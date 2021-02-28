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
    let needSuggestView: Bool = true
    
    static let hiraTabKeyModel = FlickTabKeyModel(labelType:.text("あいう"), tab: .user_dependent(.japanese), flickKeys: [:])
    static let abcTabKeyModel = FlickTabKeyModel(labelType:.text("abc"), tab: .user_dependent(.english), flickKeys: [
        .right: FlickedKeyModel(
            labelType: .text("→"),
            pressActions: [.moveCursor(1)],
            longPressActions: [.repeat(.moveCursor(1))]
        )
    ])
    static let numberTabKeyModel = FlickTabKeyModel(labelType:.text("☆123"), tab: .existential(.flick_numbersymbols), longPressActions: [.doOnce(.toggleTabBar)], flickKeys: [:])


    var pressActions: [ActionType]{ [.moveTab(self.tab)] }
    let longPressActions: [KeyLongPressActionType]

    let suggestModel: SuggestModel
    var labelType: KeyLabelType
    var tab: Tab
    let flickKeys: [FlickDirection: FlickedKeyModel]

    private init(labelType: KeyLabelType, tab: Tab, longPressActions: [KeyLongPressActionType] = [], flickKeys: [FlickDirection: FlickedKeyModel]){
        self.labelType = labelType
        self.tab = tab
        self.longPressActions = longPressActions
        self.flickKeys = flickKeys
        self.suggestModel = SuggestModel(flickKeys)
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
