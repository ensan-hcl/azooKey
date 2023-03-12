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
    func registerAction(_ action: ActionType) {}
    func registerActions(_ actions: [ActionType]) {}
    func reserveLongPressAction(_ action: LongpressActionType) {}
    func registerLongPressActionEnd(_ action: LongpressActionType) {}
    func notifyComplete(_ candidate: any ResultViewItemData) {}
    func notifySomethingWillChange(left: String, center: String, right: String) {}
    func notifySomethingDidChange(a_left: String, a_center: String, a_right: String) {}

    func makeChangeKeyboardButtonView() -> ChangeKeyboardButtonView {
        ChangeKeyboardButtonView(selector: nil, size: Design.fonts.iconFontSize)
    }
}
