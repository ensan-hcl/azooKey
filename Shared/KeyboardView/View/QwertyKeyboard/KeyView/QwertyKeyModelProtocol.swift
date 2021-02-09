//
//  QwertyKeyModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol QwertyKeyModelProtocol{
    var pressActions: [ActionType] {get}
    var longPressActions: [KeyLongPressActionType] {get}
    var keySize: CGSize {get}
    var needSuggestView: Bool {get}
    
    var variableSection: QwertyKeyModelVariableSection {get set}
    
    var variationsModel: VariationsModel {get}

    func label(states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color

    func press()
    func longPressReserve()
    func longPressEnd()

    func sound()
}


extension QwertyKeyModelProtocol{
    func press(){
        self.pressActions.forEach{VariableStates.shared.action.registerAction($0)}
    }
    
    func longPressReserve(){
        self.longPressActions.forEach{VariableStates.shared.action.reserveLongPressAction($0)}
    }
    
    func longPressEnd(){
        self.longPressActions.forEach{VariableStates.shared.action.registerLongPressActionEnd($0)}
    }
        
    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.normalKeyFillColor.color
    }
}
