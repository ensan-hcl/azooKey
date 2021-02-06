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

    var color: Color {
        switch self {
        case .normal:
            return Design.shared.colors.normalKeyColor
        case .tabkey:
            return Design.shared.colors.specialKeyColor
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
    func label(states: VariableStates) -> KeyLabel
    func backGroundColorWhenPressed(states: VariableStates) -> Color
    func backGroundColorWhenUnpressed(states: VariableStates) -> Color

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
        self.pressActions.forEach{Store.shared.action.registerAction($0)}
    }
    
    func longPressReserve(){
        self.longPressActions.forEach{Store.shared.action.reserveLongPressAction($0)}
    }
    
    func longPressEnd(){
        self.longPressActions.forEach{Store.shared.action.registerLongPressActionEnd($0)}
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
    
    func backGroundColorWhenPressed(states: VariableStates) -> Color {
        Design.shared.colors.highlightedKeyColor
    }
    func backGroundColorWhenUnpressed(states: VariableStates) -> Color {
        Design.shared.colors.normalKeyColor
    }
    func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        return 25
    }

}

