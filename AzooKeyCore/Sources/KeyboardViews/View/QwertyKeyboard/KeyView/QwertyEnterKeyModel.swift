//
//  QwertyEnterKeyView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyEnterKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {
    let keySizeType: QwertyKeySizeType
    init(keySizeType: QwertyKeySizeType) {
        self.keySizeType = keySizeType
    }

    static var shared: Self { QwertyEnterKeyModel(keySizeType: .enter) }

    var variationsModel = VariationsModel([])

    let needSuggestView: Bool = false

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        switch variableStates.enterKeyState {
        case .complete:
            return [.enter]
        case .return:
            return [.input("\n")]
        }
    }

    let longPressActions: LongpressActionType = .none

    func label<E: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<E> {
        let text = Design.language.getEnterKeyText(states.enterKeyState)
        return KeyLabel(.text(text), width: width, textSize: .small, textColor: color)
    }

    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .enter

    func feedback(variableStates: VariableStates) {
        switch variableStates.enterKeyState {
        case .complete:
            KeyboardFeedback<Extension>.tabOrOtherKey()
        case let .return(type):
            switch type {
            case .default:
                KeyboardFeedback<Extension>.click()
            default:
                KeyboardFeedback<Extension>.tabOrOtherKey()
            }
        }
    }
}
