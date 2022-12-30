//
//  UserActionManager.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
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

    func makeChangeKeyboardButtonView() -> ChangeKeyboardButtonView {
        ChangeKeyboardButtonView(selector: nil, size: Design.fonts.iconFontSize)
    }
}
