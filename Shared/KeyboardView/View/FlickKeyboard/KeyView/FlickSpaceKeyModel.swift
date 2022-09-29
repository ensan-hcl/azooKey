//
//  FlickSpaceKeyModel.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/07.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickSpaceKeyModel: FlickKeyModelProtocol {
    static let shared = FlickSpaceKeyModel()
    let suggestModel: SuggestModel
    let needSuggestView = true

    init() {
        self.suggestModel = SuggestModel(flickKeys, keyType: .normal)
    }

    let pressActions: [ActionType] = [.input(" ")]

    let longPressActions: LongpressActionType = .init(start: [.toggleShowMoveCursorView])

    let flickKeys: [FlickDirection: FlickedKeyModel] = [
        .left: FlickedKeyModel(
            labelType: .text("←"),
            pressActions: [.moveCursor(-1)],
            longPressActions: .init(repeat: [.moveCursor(-1)])
        ),
        .top: FlickedKeyModel(
            labelType: .text("全角"),
            pressActions: [.input("　")]
        ),
        .bottom: FlickedKeyModel(
            labelType: .text("Tab"),
            pressActions: [.input("\u{0009}")]
        )
    ]

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(.text("空白"), width: width)
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.specialKeyFillColor.color
    }

    func sound() {
        self.pressActions.first?.sound()
    }

}
