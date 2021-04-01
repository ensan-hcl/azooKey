//
//  KeyModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum FlickKeyColorType {
    case normal
    case tabkey
    case selected

    func color(theme: ThemeData) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .tabkey:
            return theme.specialKeyFillColor.color
        case .selected:
            return theme.pushedKeyFillColor.color
        }
    }
}

protocol FlickKeyModelProtocol {
    var suggestModel: SuggestModel {get}
    var pressActions: [ActionType] {get}
    var longPressActions: LongpressActionType {get}
    var flickKeys: [FlickDirection: FlickedKeyModel] {get}
    var needSuggestView: Bool {get}

    // 描画に関わるものは変数としてVariableStatesを受け取る。こうすることでVariableStatesの更新に合わせて変更されるようになる。
    func label(width: CGFloat, states: VariableStates) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color

    func isFlickAble(to direction: FlickDirection) -> Bool
    func press()
    func longPressReserve()
    func longPressEnd()
    func flick(to direction: FlickDirection)
    func suggestStateChanged(_ type: SuggestState)

    func flickSensitivity(to direction: FlickDirection) -> CGFloat
    func sound()

}

extension FlickKeyModelProtocol {
    func isFlickAble(to direction: FlickDirection) -> Bool {
        return flickKeys.keys.contains(direction)
    }

    func press() {
        self.pressActions.forEach {VariableStates.shared.action.registerAction($0)}
    }

    func longPressReserve() {
        VariableStates.shared.action.reserveLongPressAction(longPressActions)
    }

    func longPressEnd() {
        VariableStates.shared.action.registerLongPressActionEnd(longPressActions)
    }

    func flick(to direction: FlickDirection) {
        self.flickKeys[direction]?.flick()
    }

    func suggestStateChanged(_ type: SuggestState) {
        self.suggestModel.setSuggestState(type)
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.normalKeyFillColor.color
    }

    func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        return 25
    }

}
