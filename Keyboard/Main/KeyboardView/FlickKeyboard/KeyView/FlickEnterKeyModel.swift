//
//  EnterKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickEnterKeyModel: FlickKeyModelProtocol, EnterKeyModelProtocol{
    static var shared = FlickEnterKeyModel()
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()
    let suggestModel: SuggestModel
    let needSuggestView = false
    
    init(){
        self.suggestModel = SuggestModel([:], keyType: .enter)
    }
    
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
    
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        return [:]
    }
    
    var keySize: CGSize {
        return Design.shared.flickEnterKeySize
    }
    
    var label: KeyLabel {
        let text = Store.shared.languageDepartment.getEnterKeyText(variableSection.enterKeyState)
        return KeyLabel(.text(text), width: keySize.width)
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
