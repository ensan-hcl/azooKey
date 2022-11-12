//
//  QwertyKeyModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum QwertyKeySizeType {
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

    func height(design: TabDependentDesign) -> CGFloat {
        switch self {
        case let .unit(_, height: height):
            return design.keyViewHeight(heightCount: height)
        default:
            return design.keyViewHeight
        }
    }

}

enum QwertyUnpressedKeyColorType {
    case normal
    case special
    case enter
    case selected
    case unimportant

    func color(states: VariableStates, theme: ThemeData) -> Color {
        switch self {
        case .normal:
            return theme.normalKeyFillColor.color
        case .special:
            return theme.specialKeyFillColor.color
        case .selected:
            return theme.pushedKeyFillColor.color
        case .unimportant:
            return Color.init(white: 0, opacity: 0.001)
        case .enter:
            switch states.enterKeyState {
            case .complete, .edit:
                return theme.specialKeyFillColor.color
            case let .return(type):
                switch type {
                case .default:
                    return theme.specialKeyFillColor.color
                default:
                    if theme == .default {
                        return Design.colors.specialEnterKeyColor
                    } else {
                        return theme.specialKeyFillColor.color
                    }
                }
            }
        }
    }
}

protocol QwertyKeyModelProtocol {
    var pressActions: [ActionType] {get}
    var longPressActions: LongpressActionType {get}
    var keySizeType: QwertyKeySizeType {get}
    var needSuggestView: Bool {get}

    var variationsModel: VariationsModel {get}

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel
    func backGroundColorWhenPressed(theme: ThemeData) -> Color
    var unpressedKeyColorType: QwertyUnpressedKeyColorType {get}

    func press()
    func longPressReserve()
    func longPressEnd()

    func sound()
}

extension QwertyKeyModelProtocol {
    func press() {
        VariableStates.shared.action.registerActions(self.pressActions)
    }

    func longPressReserve() {
        VariableStates.shared.action.reserveLongPressAction(longPressActions)
    }

    func longPressEnd() {
        VariableStates.shared.action.registerLongPressActionEnd(longPressActions)
    }

    func backGroundColorWhenPressed(theme: ThemeData) -> Color {
        theme.pushedKeyFillColor.color
    }
}
