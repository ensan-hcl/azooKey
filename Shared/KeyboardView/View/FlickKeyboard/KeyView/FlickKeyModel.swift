//
//  KeyModel.swift
//  Keyboard
//
//  Created by ensan on 2020/04/11.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

// M：基本は変わらない
struct FlickKeyModel: FlickKeyModelProtocol {
    static let delete = FlickKeyModel(labelType: .image("delete.left"), pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)]), flickKeys: [
        .left: FlickedKeyModel(
            labelType: .image("xmark"),
            pressActions: [.smoothDelete]
        )
    ], needSuggestView: false, keycolorType: .tabkey)

    let needSuggestView: Bool
    private let flickKeys: [FlickDirection: FlickedKeyModel]

    let labelType: KeyLabelType
    private let pressActions: [ActionType]
    let longPressActions: LongpressActionType
    private let keycolorType: FlickKeyColorType

    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: LongpressActionType = .none, flickKeys: [FlickDirection: FlickedKeyModel], needSuggestView: Bool = true, keycolorType: FlickKeyColorType = .normal) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.flickKeys = flickKeys
        self.needSuggestView = needSuggestView
        self.keycolorType = keycolorType
    }

    func backGroundColorWhenUnpressed(states: VariableStates, theme: ThemeData) -> Color {
        keycolorType.color(theme: theme)
    }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        self.pressActions
    }

    func flickKeys(variableStates: VariableStates) -> [FlickDirection: FlickedKeyModel] {
        self.flickKeys
    }

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func feedback(variableStates: VariableStates) {
        self.pressActions.first?.feedback(variableStates: variableStates)
    }
}
