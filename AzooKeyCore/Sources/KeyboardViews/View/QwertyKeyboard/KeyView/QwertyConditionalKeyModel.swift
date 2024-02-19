//
//  QwertyConditionalKeyModel.swift
//
//
//  Created by miwa on 2024/01/20.
//

import Foundation
import SwiftUI
import enum CustardKit.TabData
import enum KanaKanjiConverterModule.KeyboardLanguage

struct QwertyConditionalKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: QwertyKeyModelProtocol {
    var keySizeType: QwertyKeySizeType

    var needSuggestView: Bool

    var variationsModel: VariationsModel = .init([])

    var unpressedKeyColorType: QwertyUnpressedKeyColorType

    /// 条件に基づいてモデルを返すclosure
    var key: (VariableStates) -> (any QwertyKeyModelProtocol<Extension>)

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        key(variableStates).pressActions(variableStates: variableStates)
    }

    func longPressActions(variableStates: VariableStates) -> LongpressActionType {
        key(variableStates).longPressActions(variableStates: variableStates)
    }

    func label<E: ApplicationSpecificKeyboardViewExtension>(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel<E> {
        key(states).label(width: width, states: states, color: color)
    }

    func feedback(variableStates: VariableStates) {
        key(variableStates).feedback(variableStates: variableStates)
    }
}
