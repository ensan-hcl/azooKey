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
        return CGSize(width: Design.shared.romanSpaceKeyWidth, height: Design.shared.keyViewSize.height)
    }
    var backGroundColorWhenUnpressed: Color {
        return Design.shared.colors.normalKeyColor
    }
    
    init(){}

    func getLabel() -> KeyLabel {
        let width = self.keySize.width
        switch Store.shared.keyboardLanguage{
        case .english:
            return KeyLabel(.text("space"), width: width, textSize: .small)
        case .japanese:
            return KeyLabel(.text("空白"), width: width, textSize: .small)
        }
    }

    func sound() {
        SoundTools.click()
    }
}
