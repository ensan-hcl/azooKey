//
//  RomanChangeTabKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

//symbolタブ、123タブで表示される切り替えボタン
struct RomanChangeTabKeyModel: RomanKeyModelProtocol{
    var variableSection = RomanKeyModelVariableSection()

    var pressActions: [ActionType]{
        switch Store.shared.needsInputModeSwitchKey{
        case true:
            switch Store.shared.keyboardLanguage{
            case .japanese:
                return [.moveTab(.hira)]
            case .english:
                return [.moveTab(.abc)]
            }
        case false:
            return []
        }

    }
    let longPressActions: [KeyLongPressActionType] = []
    ///暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false
    private let rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)

    var keySize: CGSize {
        return CGSize(
            width: Store.shared.design.romanFunctionalKeyWidth(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space),
            height: Store.shared.design.keyViewSize.height
        )
    }

    var backGroundColorWhenUnpressed: Color {
        return Store.shared.design.colors.specialKeyColor
    }

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)){
        self.rowInfo = rowInfo
    }

    func getLabel() -> KeyLabel {
        switch Store.shared.needsInputModeSwitchKey{
        case true:
            switch Store.shared.keyboardLanguage{
            case .japanese:
                return KeyLabel(.text("あ"), width: self.keySize.width)
            case .english:
                return KeyLabel(.text("A"), width: self.keySize.width)
            }
        case false:
            return KeyLabel(.text("あ"), width: self.keySize.width)
        }
    }

    func sound() {
        SoundTools.tabOrOtherKey()
    }
}
