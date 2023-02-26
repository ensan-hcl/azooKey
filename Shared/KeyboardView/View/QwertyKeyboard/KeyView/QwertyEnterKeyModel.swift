//
//  QwertyEnterKeyView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyEnterKeyModel: QwertyKeyModelProtocol {
    let keySizeType: QwertyKeySizeType
    init(keySizeType: QwertyKeySizeType) {
        self.keySizeType = keySizeType
    }

    static var shared = QwertyEnterKeyModel(keySizeType: .enter)

    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    var pressActions: [ActionType] {
        switch VariableStates.shared.enterKeyState {
        case .complete:
            return [.enter]
        case .return:
            return [.input("\n")]
        case .edit:
            return [.deselectAndUseAsInputting]
        }
    }

    let longPressActions: LongpressActionType = .none

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width, textSize: .small, textColor: color)
    }

    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .enter

    func sound() {
        switch VariableStates.shared.enterKeyState {
        case .complete, .edit:
            KeyboardFeedback.tabOrOtherKey()
        case let .return(type):
            switch type {
            case .default:
                KeyboardFeedback.click()
            default:
                KeyboardFeedback.tabOrOtherKey()
            }
        }
    }

}
