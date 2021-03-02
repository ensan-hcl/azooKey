//
//  EnterKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate extension FlickKeySizeType{
    var suggestKeyType: SuggestModelKeyType {
        switch self{
        case .normal:
            return .normal
        case let .enter(count):
            return .enter(count)
        }
    }
}

struct FlickEnterKeyModel: FlickKeyModelProtocol{
    static var shared = FlickEnterKeyModel(keySizeType: .enter(2))
    let suggestModel: SuggestModel
    let keySizeType: FlickKeySizeType
    let needSuggestView = false
    
    init(keySizeType: FlickKeySizeType){
        self.keySizeType = keySizeType
        self.suggestModel = SuggestModel([:], keyType: keySizeType.suggestKeyType)
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
    
    var longPressActions: [LongPressActionType] {
        return []
    }
    
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        return [:]
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width)
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
