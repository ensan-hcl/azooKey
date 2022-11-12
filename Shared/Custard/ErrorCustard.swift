//
//  ErrorCustard.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import CustardKit

extension Custard {
    static let errorMessage = Custard(
        identifier: "error_message",
        language: .undefined,
        input_style: .direct,
        metadata: .init(custard_version: .v1_0, display_name: "エラーメッセージ"),
        interface: .init(
            keyStyle: .tenkeyStyle,
            keyLayout: .gridFit(.init(rowCount: 1, columnCount: 6)),
            keys: [
                .gridFit(.init(x: 0, y: 0, width: 1, height: 2)): .custom(
                    .init(
                        design: .init(label: .text("カスタードファイルが見つかりません\n正しく読み込めているか確認してください"), color: .normal),
                        press_actions: [],
                        longpress_actions: .none,
                        variations: [])
                ),
                .gridFit(.init(x: 0, y: 2)): .custom(
                    .init(
                        design: .init(label: .text("アプリで確認する"), color: .special),
                        press_actions: [.launchApplication(.init(scheme: .azooKey, target: ""))],
                        longpress_actions: .none,
                        variations: [])
                ),
                .gridFit(.init(x: 0, y: 3)): .custom(
                    .init(
                        design: .init(label: .text("前のタブに戻る"), color: .special),
                        press_actions: [.moveTab(.system(.last_tab))],
                        longpress_actions: .none,
                        variations: [])
                ),
                .gridFit(.init(x: 0, y: 4)): .custom(
                    .init(
                        design: .init(label: .text("ひらがなタブに移動"), color: .special),
                        press_actions: [.moveTab(.system(.user_japanese))],
                        longpress_actions: .none,
                        variations: [])
                ),
                .gridFit(.init(x: 0, y: 5)): .system(.changeKeyboard)
            ]
        )
    )
}
