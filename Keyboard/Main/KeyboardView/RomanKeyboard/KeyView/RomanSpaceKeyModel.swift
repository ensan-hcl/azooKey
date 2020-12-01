//
//  RomanSpaceKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct RomanSpaceKeyModel: RomanKeyModelProtocol{
    var variableSection = RomanKeyModelVariableSection()
    
    let pressActions: [ActionType] = [.input(" ")]
    var longPressActions: [KeyLongPressActionType] = [.toggleShowMoveCursorView]

    let needSuggestView: Bool = false
    let variationsModel = VariationsModel([])
    var keySize: CGSize {
        return CGSize(width: Store.shared.design.romanSpaceKeyWidth, height: Store.shared.design.keyViewSize.height)
    }
    var backGroundColorWhenUnpressed: Color {
        return Store.shared.design.colors.normalKeyColor
    }
    
    init(){}

    func getLabel() -> KeyLabel {
        let width = self.keySize.width
        switch Store.shared.keyboardModel.tabState{
        case .abc:
            return KeyLabel(.text("space"), width: width, textSize: .small)
        default:
            return KeyLabel(.text("空白"), width: width, textSize: .small)
        }
    }

    func sound() {
        SoundTools.click()
    }
}
