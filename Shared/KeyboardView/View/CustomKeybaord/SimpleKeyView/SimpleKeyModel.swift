//
//  SimpleKeyModel.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/19.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol SimpleKeyModelProtocol{
    var pressActions: [ActionType] {get}
    var longPressActions: [KeyLongPressActionType] {get}
    func press()
    func longPressReserve()
    func longPressEnd()
    func sound()
    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color
}

extension SimpleKeyModelProtocol{

    func press(){
        self.pressActions.forEach{VariableStates.shared.action.registerAction($0)}
    }

    func longPressReserve(){
        self.longPressActions.forEach{VariableStates.shared.action.reserveLongPressAction($0)}
    }

    func longPressEnd(){
        self.longPressActions.forEach{VariableStates.shared.action.registerLongPressActionEnd($0)}
    }

    func sound() {
        self.pressActions.first?.sound()
    }

}

struct SimpleKeyModel: SimpleKeyModelProtocol{
    init(keyType: SimpleKeyColorType, keyLabelType: KeyLabelType, pressActions: [ActionType], longPressActions: [KeyLongPressActionType]) {
        self.keyType = keyType
        self.keyLabelType = keyLabelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
    }

    enum SimpleKeyColorType{
        case normal
        case functional
    }

    let keyType: SimpleKeyColorType
    let keyLabelType: KeyLabelType
    let pressActions: [ActionType]
    let longPressActions: [KeyLongPressActionType]

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        KeyLabel(self.keyLabelType, width: width)
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }
    
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        switch self.keyType{
        case .normal:
            return theme.normalKeyFillColor.color
        case .functional:
            return theme.specialKeyFillColor.color
        }
    }
}

struct SimpleEnterKeyModel: SimpleKeyModelProtocol{

    var pressActions: [ActionType] {
        switch VariableStates.shared.enterKeyState{
        case .complete:
            return [.enter]
        case .return:
            return [.input("\n")]
        case .edit:
            return [.deselectAndUseAsInputting]
        }
    }

    let longPressActions: [KeyLongPressActionType] = []

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width)
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
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

struct SimpleChangeKeyboardKeyModel: SimpleKeyModelProtocol{
    var pressActions: [ActionType]{
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return []
        case false:
            return [.toggleShowMoveCursorView]
        }
    }
    let longPressActions: [KeyLongPressActionType] = []

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            return KeyLabel(.changeKeyboard, width: width)
        case false:
            return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: width)
        }
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }
}
