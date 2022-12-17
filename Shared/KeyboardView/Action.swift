//
//  Action.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import CustardKit
import CustardExpressionEvaluator

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

extension CodableActionData {
    var actionType: ActionType {
        switch self {
        case let .input(value):
            return .input(value)
        case .replaceDefault:
            return .changeCharacterType
        case let .replaceLastCharacters(value):
            return .replaceLastCharacters(value)
        case let .delete(value):
            return .delete(value)
        case .smartDeleteDefault:
            return .smoothDelete
        case let .smartDelete(value):
            return .smartDelete(value)
        case .complete:
            return .enter
        case let .moveCursor(value):
            return .moveCursor(value)
        case let .smartMoveCursor(value):
            return .smartMoveCursor(value)
        case let .moveTab(value):
            return .moveTab(value.tab)
        case .enableResizingMode:
            return .enableResizingMode
        case .toggleCursorBar:
            return .setCursorBar(.toggle)
        case .toggleCapsLockState:
            return .setBoolState(VariableStates.BoolStates.isCapsLockedKey, .toggle)
        case .toggleTabBar:
            return .setTabBar(.toggle)
        case let .launchApplication(value):
            switch value.scheme {
            case .azooKey:
                return .openApp("azooKey://" + value.target)
            case .shortcuts:
                return .openApp("shortcuts://" + value.target)
            }
        case .dismissKeyboard:
            return .dismissKeyboard
        case let .setCursorBar(value):
            return .setCursorBar(value)
        case let .setCapsLockState(value):
            return .setBoolState(VariableStates.BoolStates.isCapsLockedKey, value)
        case let .setTabBar(value):
            return .setTabBar(value)
        case let .setBoolState(state, value):
            let tokenizer = CustardExpressionTokenizer()
            let compiler = CustardExpressionCompiler()
            let tokens = tokenizer.tokenize(expression: value)
            if let compiledExpression = try? compiler.compile(tokens: tokens) {
                return ._setBoolState(state, compiledExpression)
            }
            // TODO: implement empty action and enable actual do-nothing
            return .input("")
        case let .boolSwitch(expression, trueActions, falseActions):
            let tokenizer = CustardExpressionTokenizer()
            let compiler = CustardExpressionCompiler()
            let tokens = tokenizer.tokenize(expression: expression)
            if let compiledExpression = try? compiler.compile(tokens: tokens) {
                return .boolSwitch(compiledExpression, trueAction: trueActions.map {$0.actionType}, falseAction: falseActions.map {$0.actionType})
            }
            // TODO: implement empty action and enable actual do-nothing
            return .input("")
        }
    }
}

extension CodableLongpressActionData {
    var longpressActionType: LongpressActionType {
        .init(start: self.start.map {$0.actionType}, repeat: self.repeat.map {$0.actionType})
    }
}

extension ActionType {
    func sound() {
        switch self {
        case .input:
            Sound.click()
        case .delete:
            Sound.delete()
        case .smoothDelete, .smartDelete, .smartMoveCursor:
            Sound.smoothDelete()
        case .moveTab, .enter, .changeCharacterType, .setCursorBar, .moveCursor, .enableResizingMode, .replaceLastCharacters, .setTabBar, .setBoolState, ._setBoolState:
            Sound.tabOrOtherKey()
        case .deselectAndUseAsInputting, .saveSelectedTextIfNeeded, .restoreSelectedTextIfNeeded, .openApp, .dismissKeyboard, .hideLearningMemory:
            return
        case let .boolSwitch(compiledExpression, trueAction, falseAction):
            if let condition = VariableStates.shared.boolStates.evaluateExpression(compiledExpression) {
                if condition {
                    trueAction.first?.sound()
                } else {
                    falseAction.first?.sound()
                }
            }
        #if DEBUG
        case .DEBUG_DATA_INPUT:
            return
        #endif
        }
    }
}
