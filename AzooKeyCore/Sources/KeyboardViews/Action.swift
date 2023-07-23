//
//  Action.swift
//  Keyboard
//
//  Created by ensan on 2020/04/11.
//  Copyright © 2020 ensan. All rights reserved.
//

@preconcurrency import enum CustardExpressionEvaluator.CompiledExpression
import CustardKit
import Foundation
@preconcurrency import enum KanaKanjiConverterModule.ConverterBehaviorSemantics

public enum BoolOperation: Equatable, Sendable {
    case on, off, toggle
}

public indirect enum ActionType: Equatable, Sendable {
    // テキスト関係
    case input(String, simplyInsert: Bool = false)          // テキストの入力
    case delete(Int)            // テキストの削除
    case smoothDelete           // テキストの一括削除
    case smartDelete(ScanItem)

    case insertMainDisplay(String)   // displayのproxyにテキストをそのまま入力する

    /// クリップボードからペーストする
    ///  - note: フルアクセスがない場合動作しない
    case paste

    case deselectAndUseAsInputting   // 選択を解除して編集中とみなす

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
    case moveTab(TabData)
    case setTabBar(BoolOperation)
    case setUpsideComponent(UpsideComponent?)
    // キーボードを閉じる
    case dismissKeyboard
    // アプリを開く
    case openApp(String)    // アプリを開く

    // 文字検索
    case setSearchQuery(String, [ConverterBehaviorSemantics.ReplacementTarget])

    // ステート変更
    case setBoolState(String, BoolOperation)
    // case _setBoolState(String, CompiledExpression)

    // 条件分岐アクション
    case boolSwitch(CompiledExpression, trueAction: [ActionType], falseAction: [ActionType])
}

public struct LongpressActionType: Equatable, Sendable {
    static let none = LongpressActionType()
    internal init(start: [ActionType] = [], repeat: [ActionType] = []) {
        self.start = start
        self.repeat = `repeat`
    }

    public let start: [ActionType]
    public let `repeat`: [ActionType]
}
