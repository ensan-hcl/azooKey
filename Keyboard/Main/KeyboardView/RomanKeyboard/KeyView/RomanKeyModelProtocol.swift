//
//  RomanKeyModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol RomanKeyModelProtocol{
    var pressActions: [ActionType] {get}
    var longPressActions: [KeyLongPressActionType] {get}
    var keySize: CGSize {get}
    var needSuggestView: Bool {get}
    
    var variableSection: RomanKeyModelVariableSection {get set}
    
    var variationsModel: VariationsModel {get}
    func getLabel() -> KeyLabel
    func press()
    func longPressReserve()
    func longPressEnd()
    
    var backGroundColorWhenPressed: Color {get}
    var backGroundColorWhenUnpressed: Color {get}

    func sound()
}


extension RomanKeyModelProtocol{
    func press(){
        self.pressActions.forEach{Store.shared.action.registerPressAction($0)}
    }
    
    func longPressReserve(){
        self.longPressActions.forEach{Store.shared.action.reserveLongPressAction($0)}
    }
    
    func longPressEnd(){
        self.longPressActions.forEach{Store.shared.action.registerLongPressActionEnd($0)}
    }
        
    var backGroundColorWhenPressed: Color {
        Design.shared.colors.highlightedKeyColor
    }
    var backGroundColorWhenUnpressed: Color {
        Design.shared.colors.normalKeyColor
    }
}
