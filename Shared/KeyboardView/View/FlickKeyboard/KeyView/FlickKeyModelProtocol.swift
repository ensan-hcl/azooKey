//
//  KeyModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum FlickKeyColorType{
    case normal
    case tabkey

    func color(theme: ThemeData) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .tabkey:
            return theme.specialKeyFillColor.color
        }
    }
}

protocol FlickKeyModelProtocol {
    var suggestModel: SuggestModel {get}
    var pressActions: [ActionType] {get}
    var longPressActions: [KeyLongPressActionType] {get}
    var flickKeys: [FlickDirection: FlickedKeyModel] {get}
    var keySize: CGSize {get}
    var needSuggestView: Bool {get}
    
    var variableSection: KeyModelVariableSection {get set}

    //描画に関わるものは変数としてVariableStatesを受け取る。こうすることでVariableStatesの更新に合わせて変更されるようになる。
    func label(states: VariableStates, theme: ThemeData) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color

    func isFlickAble(to direction: FlickDirection) -> Bool
    func press()
    func longPressReserve()
    func longPressEnd()
    func flick(to direction: FlickDirection)
    func suggestStateChanged(_ type: SuggestState)

    func flickSensitivity(to direction: FlickDirection) -> CGFloat
    func sound()

}

extension ActionType{
    func sound(){
        switch self{
        case .input(_):
            Sound.click()
        case .delete(_):
            Sound.delete()
        case .smoothDelete:
            Sound.smoothDelete()
        case .moveTab(_), .enter, .changeCharacterType, .toggleShowMoveCursorView, .moveCursor(_):
            Sound.tabOrOtherKey()
        default:
            return
        }
    }
}

extension FlickKeyModelProtocol{
    func isFlickAble(to direction: FlickDirection) -> Bool {
        return flickKeys.keys.contains(direction)
    }
    
    func press(){
        self.pressActions.forEach{VariableStates.shared.action.registerAction($0)}
    }
    
    func longPressReserve(){
        self.longPressActions.forEach{VariableStates.shared.action.reserveLongPressAction($0)}
    }
    
    func longPressEnd(){
        self.longPressActions.forEach{VariableStates.shared.action.registerLongPressActionEnd($0)}
    }
    
    func flick(to direction: FlickDirection){
        self.flickKeys[direction]?.flick()
    }
    
    func suggestStateChanged(_ type: SuggestState){
        self.suggestModel.setSuggestState(type)
    }
    
    var keySize: CGSize {
        return Design.shared.keyViewSize
    }
    
    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.normalKeyFillColor.color
    }
    func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        return 25
    }

}

