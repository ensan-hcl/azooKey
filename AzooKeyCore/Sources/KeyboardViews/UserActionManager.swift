//
//  UserActionManager.swift
//  Keyboard
//
//  Created by ensan on 2021/02/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import KeyboardExtensionUtils

/// キーボードの操作を管理するためのクラス
@MainActor open class UserActionManager {
    public init() {}
    open func registerAction(_ action: ActionType, variableStates: VariableStates) {}
    open func registerActions(_ actions: [ActionType], variableStates: VariableStates) {}
    open func reserveLongPressAction(_ action: LongpressActionType, variableStates: VariableStates) {}
    open func registerLongPressActionEnd(_ action: LongpressActionType) {}
    open func setTextDocumentProxy(_ proxy: AnyTextDocumentProxy) {}
    open func notifyComplete(_ candidate: any ResultViewItemData, variableStates: VariableStates) {}
    open func notifyForgetCandidate(_ candidate: any ResultViewItemData, variableStates: VariableStates) {}
    open func notifyReportWrongConversion(_ candidate: any ResultViewItemData, index: Int?, variableStates: VariableStates) async {}
    open func notifySomethingWillChange(left: String, center: String, right: String) {}
    open func notifySomethingDidChange(a_left: String, a_center: String, a_right: String, variableStates: VariableStates) {}

    open func makeChangeKeyboardButtonView<Extension: ApplicationSpecificKeyboardViewExtension>() -> ChangeKeyboardButtonView<Extension> {
        ChangeKeyboardButtonView(selector: nil, size: Design.fonts.iconFontSize(keyViewFontSizePreference: Extension.SettingProvider.keyViewFontSize))
    }
}
