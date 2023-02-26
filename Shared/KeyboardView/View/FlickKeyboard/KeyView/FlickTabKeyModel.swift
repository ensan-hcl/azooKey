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
    private let key: CustomizableFlickKey
    let needSuggestView: Bool = true

    static let hiraTabKeyModel = FlickTabKeyModel(tab: .user_dependent(.japanese), key: .hiraTab)
    static let abcTabKeyModel = FlickTabKeyModel(tab: .user_dependent(.english), key: .abcTab)
    static let numberTabKeyModel = FlickTabKeyModel(tab: .existential(.flick_numbersymbols), key: .symbolsTab)

    var pressActions: [ActionType] {
        key.get().actions
    }
    var longPressActions: LongpressActionType {
        key.get().longpressActions
    }
    var labelType: KeyLabelType {
        key.get().labelType
    }
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        key.get().flick
    }

    let suggestModel: SuggestModel
    var tab: Tab

    private init(tab: Tab, key: CustomizableFlickKey) {
        self.key = key
        self.tab = tab
        self.suggestModel = SuggestModel([:], keyType: .custom(key))
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        if states.tabManager.isCurrentTab(tab: tab) {
            return theme.pushedKeyFillColor.color
        }
        return theme.specialKeyFillColor.color
    }

    func sound() {
        KeyboardFeedback.tabOrOtherKey()
    }
}
