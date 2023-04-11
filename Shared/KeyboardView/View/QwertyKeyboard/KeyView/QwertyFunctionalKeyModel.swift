//
//  QwertyFunctionalKeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyFunctionalKeyModel: QwertyKeyModelProtocol {
    static var delete = QwertyFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)]))

    private let pressActions: [ActionType]
    var longPressActions: LongpressActionType
    /// 暫定
    let variationsModel = VariationsModel([])

    let labelType: KeyLabelType
    let needSuggestView: Bool
    let keySizeType: QwertyKeySizeType
    let unpressedKeyColorType: QwertyUnpressedKeyColorType = .special

    init(labelType: KeyLabelType, rowInfo: (normal: Int, functional: Int, space: Int, enter: Int), pressActions: [ActionType], longPressActions: LongpressActionType = .none, needSuggestView: Bool = false) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.needSuggestView = needSuggestView
        self.keySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        self.pressActions
    }

    func label(width: CGFloat, states: VariableStates, color: Color?) -> KeyLabel {
        KeyLabel(self.labelType, width: width, textColor: color)
    }

    func feedback(variableStates: VariableStates) {
        self.pressActions.first?.feedback(variableStates: variableStates)
    }

}
