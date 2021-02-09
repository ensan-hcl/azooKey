//
//  EnterKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickEnterKeyModel: FlickKeyModelProtocol{
    static var shared = FlickEnterKeyModel()
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()
    let suggestModel: SuggestModel
    let needSuggestView = false
    
    init(){
        self.suggestModel = SuggestModel([:], keyType: .enter)
    }
    
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
    
    var longPressActions: [KeyLongPressActionType] {
        return []
    }
    
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        return [:]
    }
    
    var keySize: CGSize {
        return Design.shared.flickEnterKeySize
    }

    func label(states: VariableStates, theme: ThemeData) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: keySize.width, theme: theme)
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
    
    func sound() {
        switch VariableStates.shared.enterKeyState{
        case .complete, .edit:
            Sound.tabOrOtherKey()
        case let .return(type):
            switch type{
            case .default:
                Sound.click()
            default:
                Sound.tabOrOtherKey()
            }
        }
    }
    
}
