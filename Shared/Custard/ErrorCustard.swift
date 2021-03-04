//
//  ErrorCustard.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension Custard{
    static let errorMessage = Custard(
        custard_version: .v1_0,
        identifier: "error_message",
        display_name: "エラーメッセージ",
        language: .undefined,
        input_style: .direct,
        interface: .init(
            key_style: .flick,
            key_layout: .gridFit(.init(width: 1, height: 6)),
            keys: [
                .grid_fit(.init(x: 0, y: 0)): .custom(
                    .init(
                        design: .init(label: .text("カスタードファイルが見つかりません"), color: .normal),
                        press_actions: [],
                        longpress_actions: [],
                        variations: [])
                ),
                .grid_fit(.init(x: 0, y: 1)): .custom(
                    .init(
                        design: .init(label: .text("正しく読み込めているか確認してください"), color: .normal),
                        press_actions: [],
                        longpress_actions: [],
                        variations: [])
                ),
                .grid_fit(.init(x: 0, y: 2)): .custom(
                    .init(
                        design: .init(label: .text("アプリで確認する"), color: .special),
                        press_actions: [.openURL("azooKey://")],
                        longpress_actions: [],
                        variations: [])
                ),
                .grid_fit(.init(x: 0, y: 3)): .custom(
                    .init(
                        design: .init(label: .text("前のタブに戻る"), color: .special),
                        press_actions: [.moveTab(.system(.last_tab))],
                        longpress_actions: [],
                        variations: [])
                ),
                .grid_fit(.init(x: 0, y: 4)): .custom(
                    .init(
                        design: .init(label: .text("ひらがなタブに移動"), color: .special),
                        press_actions: [.moveTab(.system(.user_japanese))],
                        longpress_actions: [],
                        variations: [])
                ),
                .grid_fit(.init(x: 0, y: 5)): .system(.change_keyboard)
            ]
        )
    )
}
