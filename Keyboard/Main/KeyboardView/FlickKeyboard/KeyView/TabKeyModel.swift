//
//  TabKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct TabKeyModel: FlickKeyModelProtocol{
    let needSuggestView: Bool = true
    
    static let hiraTabKeyModel = TabKeyModel(labelType:.text("あいう"),tabType: .hira, flickKeys: [:])
    static let abcTabKeyModel = TabKeyModel(labelType:.text("abc"), tabType: .abc, flickKeys: [
        .right: FlickedKeyModel(
            labelType: .text("→"),
            pressActions: [.moveCursor(1)],
            longPressActions: [.moveCursor(.right)]
        )
    ])
    static let numberTabKeyModel = TabKeyModel(labelType:.text("☆123"), tabType: .number, flickKeys: [:])
       // .top: FlickedKeyModel(labelType: .image("lock"), pressActions: [.hideLearningMemory]) //見送る。


    var pressActions: [ActionType]{ [.moveTab(self.tabType)] }
    var longPressActions: [KeyLongPressActionType]{ [] }
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()

    let suggestModel: SuggestModel
    var labelType: KeyLabelType
    var tabType: TabState
    let flickKeys: [FlickDirection: FlickedKeyModel]

    init(labelType: KeyLabelType, tabType: TabState, flickKeys: [FlickDirection: FlickedKeyModel]){
        self.labelType = labelType
        self.tabType = tabType
        self.flickKeys = flickKeys
        self.suggestModel = SuggestModel(flickKeys)
    }

    var label: KeyLabel {
        return KeyLabel(self.labelType, width: keySize.width)
    }

    var backGroundColorWhenUnpressed: Color {
        if self.variableSection.keyboardState == self.tabType{
            return Design.shared.colors.highlightedKeyColor

        }
        return Design.shared.colors.specialKeyColor

    }
    
    func setKeyboardState(new state: TabState){
        if self.variableSection.keyboardState != state{
            self.variableSection.keyboardState = state
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }

}

extension TabKeyModel{
    func withFlick(_ flickKeys: [FlickDirection: FlickedKeyModel]) -> TabKeyModel {
        return TabKeyModel(labelType: self.labelType, tabType: self.tabType, flickKeys: flickKeys)
    }
}
