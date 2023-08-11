//
//  QwertyKeyModelProtocol.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import KeyboardThemes
import SwiftUI

enum QwertyKeySizeType: Sendable {
    case unit(width: Int, height: Int)
    case normal(of: Int, for: Int)
    case functional(normal: Int, functional: Int, enter: Int, space: Int)
    case enter
    case space

    func width(design: TabDependentDesign) -> CGFloat {
        switch self {
        case let .unit(width: width, _):
            return design.keyViewWidth(widthCount: width)
        case let .normal(of: normalCount, for: keyCount):
            return design.qwertyScaledKeyWidth(normal: normalCount, for: keyCount)
        case let .functional(normal: normal, functional: functional, enter: enter, space: space):
            return design.qwertyFunctionalKeyWidth(normal: normal, functional: functional, enter: enter, space: space)
        case .enter:
            return design.qwertyEnterKeyWidth
        case .space:
            return design.qwertySpaceKeyWidth
        }
    }

    @MainActor func height(design: TabDependentDesign) -> CGFloat {
        switch self {
        case let .unit(_, height: height):
            return design.keyViewHeight(heightCount: height)
        default:
            return design.keyViewHeight
        }
    }

}

enum QwertyUnpressedKeyColorType: Sendable {
    case normal
    case special
    case enter
    case selected
    case unimportant

    func color<ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(states: VariableStates, theme: ThemeData<ThemeExtension>) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .special:
            return theme.specialKeyFillColor.color
        case .selected:
            return theme.pushedKeyFillColor.color
        case .unimportant:
            return Color(white: 0, opacity: 0.001)
        case .enter:
            switch states.enterKeyState {
            case .complete, .edit:
                return theme.specialKeyFillColor.color
            case let .return(type):
                switch type {
                case .default:
                    return theme.specialKeyFillColor.color
                default:
                    if theme == ThemeExtension.default(layout: .qwerty) {
                        return Design.colors.specialEnterKeyColor
                    } else {
                        return theme.specialKeyFillColor.color
                    }
                }
            }
        }
    }
}

protocol QwertyKeyModelProtocol<Extension> {
    associatedtype Extension: ApplicationSpecificKeyboardViewExtension

    var longPressActions: LongpressActionType {get}
    var keySizeType: QwertyKeySizeType {get}
    var needSuggestView: Bool {get}

    var variationsModel: VariationsModel {get}

    @MainActor func pressActions(variableStates: VariableStates) -> [ActionType]
    /// 二回連続で押した際に発火するActionを指定する
    @MainActor func doublePressActions(variableStates: VariableStates) -> [ActionType]
    @MainActor func label<Extension: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<Extension>
    func backGroundColorWhenPressed(theme: Extension.Theme) -> Color
    var unpressedKeyColorType: QwertyUnpressedKeyColorType {get}

    @MainActor func feedback(variableStates: VariableStates)
}

extension QwertyKeyModelProtocol {
    func backGroundColorWhenPressed(theme: ThemeData<some ApplicationSpecificTheme>) -> Color {
        theme.pushedKeyFillColor.color
    }
    func doublePressActions(variableStates: VariableStates) -> [ActionType] {
        []
    }
}
