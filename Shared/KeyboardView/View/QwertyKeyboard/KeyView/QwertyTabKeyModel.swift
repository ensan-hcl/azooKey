//
//  QwertyChangeTabKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/12/14.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

// symbolタブ、123タブで表示される切り替えボタン
struct QwertyTabKeyModel: QwertyKeyModelProtocol {

    var pressActions: [ActionType] {
        switch SemiStaticStates.shared.needsInputModeSwitchKey {
        case true:
            switch VariableStates.shared.keyboardLanguage {
            case .ja_JP, .none, .el_GR:
                return [.moveTab(.user_dependent(.japanese))]
            case .en_US:
                return [.moveTab(.user_dependent(.english))]
            }
        case false:
            return [.moveTab(.user_dependent(.japanese))]
        }

    }
    let longPressActions: LongpressActionType = .none
    /// 暫定
    let variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)) {
        self.keySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey {
        case true:
            switch states.keyboardLanguage {
            case .ja_JP, .none, .el_GR:
                return KeyLabel(.text("あ"), width: width, textColor: color)
            case .en_US:
                return KeyLabel(.text("A"), width: width, textColor: color)
            }
        case false:
            return KeyLabel(.text("あ"), width: width, textColor: color)
        }
    }

    func sound() {
        KeyboardFeedback.tabOrOtherKey()
    }
}
