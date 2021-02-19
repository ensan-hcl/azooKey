//
//  QwertyEnterKeyView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyEnterKeyModel: QwertyKeyModelProtocol{
    init(){}

    static var shared = QwertyEnterKeyModel()
    var variableSection = QwertyKeyModelVariableSection()
    var keySize: CGSize {
        return CGSize(width: Design.shared.qwertyEnterKeyWidth, height: Design.shared.keyViewHeight)
    }
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

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
    
    func label(states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: self.keySize.width, theme: theme, textSize: .small, textColor: color)
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
