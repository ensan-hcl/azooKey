//
//  Action.swift
//  Keyboard
//
//  Created by ensan on 2020/04/11.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardExpressionEvaluator
import CustardKit
import Foundation

indirect enum ActionType: Equatable {
    // テキスト関係
    case input(String)          // テキストの入力
    case delete(Int)            // テキストの削除
    case smoothDelete           // テキストの一括削除
    case smartDelete(ScanItem)

    case deselectAndUseAsInputting   // 選択を解除して編集中とみなす
    // 取り込み関係
    case saveSelectedTextIfNeeded           // 選択部分が存在していたら一時保存する。
    case restoreSelectedTextIfNeeded        // 選択部分の一時保存したデータを取り出して代入する
    // カーソル関係
    case moveCursor(Int)
    case smartMoveCursor(ScanItem)

    case setCursorBar(BoolOperation)
    case enableResizingMode
    // 変換関連
    case enter
    case changeCharacterType    // 濁点、半濁点、小さい文字
    case replaceLastCharacters([String: String])
    case hideLearningMemory
    // タブの変更
    case moveTab(Tab)
    case setTabBar(BoolOperation)

    // キーボードを閉じる
    case dismissKeyboard
    // アプリを開く
    case openApp(String)    // アプリを開く

    // ステート変更
    case setBoolState(String, BoolOperation)
    case _setBoolState(String, CompiledExpression)

    // 条件分岐アクション
    case boolSwitch(CompiledExpression, trueAction: [ActionType], falseAction: [ActionType])

    #if DEBUG
    // デバッグ用
    case DEBUG_DATA_INPUT
    #endif
}

struct LongpressActionType: Equatable {
    static let none = LongpressActionType()
    internal init(start: [ActionType] = [], repeat: [ActionType] = []) {
        self.start = start
        self.repeat = `repeat`
    }

    let start: [ActionType]
    let `repeat`: [ActionType]
}
