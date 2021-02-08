//
//  QwertyChangeTabKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/12/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

//symbolタブ、123タブで表示される切り替えボタン
struct QwertyChangeTabKeyModel: QwertyKeyModelProtocol{
    var variableSection = QwertyKeyModelVariableSection()

    var pressActions: [ActionType]{
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            switch VariableStates.shared.keyboardLanguage{
            case .japanese:
                return [.moveTab(.hira)]
            case .english:
                return [.moveTab(.abc)]
            }
        case false:
            return [.moveTab(.hira)]
        }

    }
    let longPressActions: [KeyLongPressActionType] = []
    ///暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false
    private let rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)

    var keySize: CGSize {
        return CGSize(
            width: Design.shared.qwertyFunctionalKeyWidth(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space),
            height: Design.shared.keyViewSize.height
        )
    }

    func backGroundColorWhenUnpressed(states: VariableStates) -> Color {
        states.themeManager.theme.specialKeyFillColor.color
    }

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)){
        self.rowInfo = rowInfo
    }

    func label(states: VariableStates, color: Color? = nil) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            switch states.keyboardLanguage{
            case .japanese:
                return KeyLabel(.text("あ"), width: self.keySize.width, textColor: color)
            case .english:
                return KeyLabel(.text("A"), width: self.keySize.width, textColor: color)
            }
        case false:
            return KeyLabel(.text("あ"), width: self.keySize.width, textColor: color)
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
