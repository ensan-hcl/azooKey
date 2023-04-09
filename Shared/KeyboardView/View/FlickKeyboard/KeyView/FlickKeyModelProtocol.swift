//
//  KeyModelProtocol.swift
//  Keyboard
//
//  Created by ensan on 2020/04/12.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

enum FlickKeyColorType {
    case normal
    case tabkey
    case selected
    case unimportant

    func color(theme: ThemeData) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .tabkey:
            return theme.specialKeyFillColor.color
        case .selected:
            return theme.pushedKeyFillColor.color
        case .unimportant:
            return Color(white: 0, opacity: 0.001)
        }
    }
}

protocol FlickKeyModelProtocol {
    var longPressActions: LongpressActionType {get}
    var needSuggestView: Bool {get}

    @MainActor func pressActions(variableStates: VariableStates) -> [ActionType]
    @MainActor func label(width: CGFloat, states: VariableStates) -> KeyLabel
    @MainActor func backGroundColorWhenPressed(theme: ThemeData) -> Color
    @MainActor func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color

    @MainActor func isFlickAble(to direction: FlickDirection, variableStates: VariableStates) -> Bool
    @MainActor func flickKeys(variableStates: VariableStates) -> [FlickDirection: FlickedKeyModel]

    @MainActor func flickSensitivity(to direction: FlickDirection) -> CGFloat
    @MainActor func feedback(variableStates: VariableStates)

}

extension FlickKeyModelProtocol {
    @MainActor func isFlickAble(to direction: FlickDirection, variableStates: VariableStates) -> Bool {
        flickKeys(variableStates: variableStates).keys.contains(direction)
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        theme.normalKeyFillColor.color
    }

    @MainActor func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        @KeyboardSetting<FlickSensitivitySettingKey>(.flickSensitivity) var flickSensitivity
        return 25 / flickSensitivity
    }

}
