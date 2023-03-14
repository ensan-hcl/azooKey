//
//  ChangeKeyboardFlickKey.swift
//  Keyboard
//
//  Created by ensan on 2020/10/19.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickChangeKeyboardModel: FlickKeyModelProtocol {
    @KeyboardSetting(.enablePasteButton) private var _enablePasteButton
    private var usePasteButton: Bool {
        !SemiStaticStates.shared.needsInputModeSwitchKey && SemiStaticStates.shared.hasFullAccess && _enablePasteButton
    }
    var needSuggestView: Bool {
        usePasteButton
    }

    static let shared = FlickChangeKeyboardModel()

    var pressActions: [ActionType] {
        switch SemiStaticStates.shared.needsInputModeSwitchKey {
        case true:
            return []
        case false:
            return [.setCursorBar(.toggle)]
        }
    }
    var longPressActions: LongpressActionType = .none

    let suggestModel = SuggestModel([:], keyType: .changeKeyboard)
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        if usePasteButton {
            return [.top: FlickedKeyModel(labelType: .image("doc.on.clipboard"), pressActions: [.paste])]
        }
        return [:]
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        switch SemiStaticStates.shared.needsInputModeSwitchKey {
        case true:
            return KeyLabel(.changeKeyboard, width: width)
        case false:
            return KeyLabel(.image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), width: width)
        }
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }

    func feedback() {
        KeyboardFeedback.tabOrOtherKey()
    }
}
