//
//  RomanEnterKeyView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct RomanEnterKeyModel: RomanKeyModelProtocol, EnterKeyModelProtocol{
    init(){}

    static var shared = RomanEnterKeyModel()
    var variableSection = RomanKeyModelVariableSection()
    var keySize: CGSize {
        return CGSize(width: Design.shared.romanEnterKeyWidth, height: Design.shared.keyViewSize.height)
    }
    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    var pressActions: [ActionType] {
        switch variableSection.enterKeyState{
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
    
    func getLabel() -> KeyLabel {
        let text = Store.shared.languageDepartment.getEnterKeyText(variableSection.enterKeyState)
        return KeyLabel(.text(text), width: self.keySize.width, textSize: .small)
    }
    
    var backGroundColorWhenUnpressed: Color {
        switch variableSection.enterKeyState{
        case .complete, .edit:
            return Design.shared.colors.specialKeyColor
        case let .return(type):
            switch type{
            case .default:
                return Design.shared.colors.specialKeyColor
            default:
                return Design.shared.colors.specialEnterKeyColor
            }
        }
    }
    
    func setKeyState(new state: EnterKeyState){
        self.variableSection.enterKeyState = state
    }

    func sound() {
        switch variableSection.enterKeyState{
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
