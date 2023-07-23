//
//  KeyModelProtocol.swift
//  Keyboard
//
//  Created by ensan on 2020/04/12.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import KeyboardThemes
import SwiftUI

enum FlickKeyColorType {
    case normal
    case tabkey
    case selected
    case unimportant

    func color(theme: ThemeData<some ApplicationSpecificTheme>) -> Color {
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

public protocol FlickKeyModelProtocol<Extension> {
    associatedtype Extension: ApplicationSpecificKeyboardViewExtension

    var longPressActions: LongpressActionType {get}
    var needSuggestView: Bool {get}

    @MainActor func pressActions(variableStates: VariableStates) -> [ActionType]
    @MainActor func backGroundColorWhenPressed<ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(theme: ThemeData<ThemeExtension>) -> Color
    @MainActor func backGroundColorWhenUnpressed<ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(states: VariableStates, theme: ThemeData<ThemeExtension>) -> Color

    @MainActor func flickKeys(variableStates: VariableStates) -> [FlickDirection: FlickedKeyModel]
    @MainActor func isFlickAble(to direction: FlickDirection, variableStates: VariableStates) -> Bool

    // FIXME: any FlickKeyModelProtocolではassociatedtypeが扱いづらい問題に対処するため、任意のExtensionに対して扱えるようにする
    // FIXME: iOS 16以降はany FlickKeyModelProtocol<Extension>を使って解消できる
    @MainActor func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates) -> KeyLabel<Extension>

    @MainActor func flickSensitivity(to direction: FlickDirection) -> CGFloat
    @MainActor func feedback(variableStates: VariableStates)

}

extension FlickKeyModelProtocol {
    @MainActor func isFlickAble(to direction: FlickDirection, variableStates: VariableStates) -> Bool {
        (flickKeys(variableStates: variableStates) as [FlickDirection: FlickedKeyModel]).keys.contains(direction)
    }

    func backGroundColorWhenPressed(theme: ThemeData<some ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>) -> Color {
        theme.pushedKeyFillColor.color
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData<some ApplicationSpecificTheme>) -> Color {
        theme.normalKeyFillColor.color
    }

    @MainActor func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        25 / Extension.SettingProvider.flickSensitivity
    }
}
