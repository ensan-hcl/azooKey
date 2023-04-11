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
    @MainActor func registerAction(_ action: ActionType, variableStates: VariableStates) {}
    @MainActor func registerActions(_ actions: [ActionType], variableStates: VariableStates) {}
    @MainActor func reserveLongPressAction(_ action: LongpressActionType, variableStates: VariableStates) {}
    @MainActor func registerLongPressActionEnd(_ action: LongpressActionType) {}
    @MainActor func setTextDocumentProxy(_ proxy: AnyTextDocumentProxy) {}
    @MainActor func notifyComplete(_ candidate: any ResultViewItemData, variableStates: VariableStates) {}
    @MainActor func notifyForgetCandidate(_ candidate: any ResultViewItemData, variableStates: VariableStates) {}
    @MainActor func notifyReportWrongConversion(_ candidate: any ResultViewItemData, index: Int?, variableStates: VariableStates) async {}
    @MainActor func notifySomethingWillChange(left: String, center: String, right: String) {}
    @MainActor func notifySomethingDidChange(a_left: String, a_center: String, a_right: String, variableStates: VariableStates) {}

    @MainActor func makeChangeKeyboardButtonView() -> ChangeKeyboardButtonView {
        ChangeKeyboardButtonView(selector: nil, size: Design.fonts.iconFontSize)
    }
}
