//
//  UserActionManager.swift
//  Keyboard
//
//  Created by ensan on 2021/02/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

/// キーボードの操作を管理するためのクラス
/// - finalにはできない
class UserActionManager {
    init() {}
    func registerAction(_ action: ActionType, variableStates: VariableStates) {}
    func registerActions(_ actions: [ActionType], variableStates: VariableStates) {}
    func reserveLongPressAction(_ action: LongpressActionType, variableStates: VariableStates) {}
    func registerLongPressActionEnd(_ action: LongpressActionType) {}
    func setTextDocumentProxy(_ proxy: AnyTextDocumentProxy) {}
    func notifyComplete(_ candidate: any ResultViewItemData, variableStates: VariableStates) {}
    func notifyForgetCandidate(_ candidate: any ResultViewItemData, variableStates: VariableStates) {}
    func notifyReportWrongConversion(_ candidate: any ResultViewItemData, index: Int?, variableStates: VariableStates) async {}
    func notifySomethingWillChange(left: String, center: String, right: String) {}
    func notifySomethingDidChange(a_left: String, a_center: String, a_right: String, variableStates: VariableStates) {}

    func makeChangeKeyboardButtonView() -> ChangeKeyboardButtonView {
        ChangeKeyboardButtonView(selector: nil, size: Design.fonts.iconFontSize)
    }
}
