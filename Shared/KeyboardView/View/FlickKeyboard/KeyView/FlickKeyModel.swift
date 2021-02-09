//
//  KeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI


//M：基本は変わらない
struct FlickKeyModel: FlickKeyModelProtocol{
    var variableSection = KeyModelVariableSection()
    
    let suggestModel: SuggestModel
    let needSuggestView: Bool
    let flickKeys: [FlickDirection: FlickedKeyModel]

    let labelType: KeyLabelType
    let pressActions: [ActionType]
    let longPressActions: [KeyLongPressActionType]
    private let keycolorType: FlickKeyColorType
    
    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: [KeyLongPressActionType] = [], flickKeys: [FlickDirection: FlickedKeyModel], needSuggestView: Bool = true, keycolorType: FlickKeyColorType = .normal){
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.flickKeys = flickKeys
        self.needSuggestView = needSuggestView
        self.suggestModel = SuggestModel(flickKeys)
        self.keycolorType = keycolorType
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        keycolorType.color(theme: theme)
    }

    func label(states: VariableStates, theme: ThemeData) -> KeyLabel {
        KeyLabel(self.labelType, width: keySize.width, theme: theme)
    }

    func sound(){
        self.pressActions.first?.sound()
    }
}

