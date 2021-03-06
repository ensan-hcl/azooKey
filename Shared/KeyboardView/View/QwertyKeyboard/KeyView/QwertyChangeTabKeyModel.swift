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

    var pressActions: [ActionType]{
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            switch VariableStates.shared.keyboardLanguage{
            case .japanese, .none, .greek:
                return [.moveTab(.user_dependent(.japanese))]
            case .english:
                return [.moveTab(.user_dependent(.english))]
            }
        case false:
            return [.moveTab(.user_dependent(.japanese))]
        }

    }
    let longPressActions: LongpressActionType = .none
    ///暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)){
        self.keySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey{
        case true:
            switch states.keyboardLanguage{
            case .japanese, .none, .greek:
                return KeyLabel(.text("あ"), width: width, textColor: color)
            case .english:
                return KeyLabel(.text("A"), width: width, textColor: color)
            }
        case false:
            return KeyLabel(.text("あ"), width: width, textColor: color)
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
