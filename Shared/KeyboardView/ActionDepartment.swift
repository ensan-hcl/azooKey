//
//  ActionDepartment.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

///キーボードの操作を管理するためのクラス
/// - finalにはできない
class ActionDepartment{
    init(){}
    func registerAction(_ action: ActionType){}
    func reserveLongPressAction(_ action: LongPressActionType){}
    func registerLongPressActionEnd(_ action: LongPressActionType){}
    func notifySomethingWillChange(left: String, center: String, right: String){}
    func notifySomethingDidChange(a_left: String, a_center: String, a_right: String){}
    func notifyComplete(_ candidate: ResultViewItemData){}
    func changeInputStyle(from beforeStyle: InputStyle, to afterStyle: InputStyle){}

    func makeChangeKeyboardButtonView(theme: ThemeData) -> ChangeKeyboardButtonView {
        ChangeKeyboardButtonView(selector: nil, size: Design.fonts.iconFontSize, theme: theme)
    }
}
