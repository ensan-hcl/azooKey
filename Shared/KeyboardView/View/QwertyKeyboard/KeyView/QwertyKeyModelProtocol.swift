//
//  QwertyKeyModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum QwertyKeySizeType{
    case normal(of: Int, for: Int)
    case functional(normal: Int, functional: Int, enter: Int, space: Int)
    case enter
    case space

    func width(design: TabDependentDesign) -> CGFloat {
        switch self{
        case let .normal(of: normalCount, for: keyCount):
            return design.qwertyScaledKeyWidth(normal: normalCount, for: keyCount)
        case let .functional(normal: normal, functional: functional, enter: enter, space: space):
            return design.qwertyFunctionalKeyWidth(normal: normal, functional: functional, enter: enter, space: space)
        case .enter:
            return design.qwertyEnterKeyWidth
        case .space:
            return design.qwertySpaceKeyWidth
        }
    }

    func height(design: TabDependentDesign) -> CGFloat {
        design.keyViewHeight
    }

}

enum QwertyUnpressedKeyColorType{
    case normal
    case special
    case enter

    func color(states: VariableStates, theme: ThemeData) -> Color {
        switch self{
        case .normal:
            return theme.normalKeyFillColor.color
        case .special:
            return theme.specialKeyFillColor.color
        case .enter:
            switch states.enterKeyState{
            case .complete, .edit:
                return theme.specialKeyFillColor.color
            case let .return(type):
                switch type{
                case .default:
                    return theme.specialKeyFillColor.color
                default:
                    if theme == .default{
                        return Design.colors.specialEnterKeyColor
                    }else{
                        return theme.specialKeyFillColor.color
                    }
                }
            }
        }
    }
}

protocol QwertyKeyModelProtocol{
    var pressActions: [ActionType] {get}
    var longPressActions: [KeyLongPressActionType] {get}
    var keySizeType: QwertyKeySizeType {get}
    var needSuggestView: Bool {get}
    
    var variableSection: QwertyKeyModelVariableSection {get set}
    
    var variationsModel: VariationsModel {get}

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    var unpressedKeyColorType: QwertyUnpressedKeyColorType {get}

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
}
