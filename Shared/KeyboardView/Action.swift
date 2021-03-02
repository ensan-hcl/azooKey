//
//  Action.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum ActionType{
    //テキスト関係
    case input(String)          //テキストの入力
    case delete(Int)            //テキストの削除
    case smoothDelete           //テキストの一括削除
    case deselectAndUseAsInputting   //選択を解除して編集中とみなす
    //取り込み関係
    case saveSelectedTextIfNeeded           //選択部分が存在していたら一時保存する。
    case restoreSelectedTextIfNeeded        //選択部分の一時保存したデータを取り出して代入する
    //カーソル関係
    case moveCursor(Int)
    case toggleShowMoveCursorView

    //変換関連
    case enter
    case changeCharacterType    //濁点、半濁点、小さい文字
    case changeCapsLockState(state: AaKeyState)
    case hideLearningMemory
    //タブの変更
    case moveTab(Tab)
    case toggleTabBar

    //キーボードを閉じる
    case dismissKeyboard
    //アプリを開く
    case openApp(String)    //アプリを開く
    #if DEBUG
    //デバッグ用
    case DEBUG_DATA_INPUT
    #endif
}

extension ActionType: Equatable{

    static func == (lsb: ActionType, rsb: ActionType) -> Bool {
        switch (lsb, rsb){
        case let (.input(l), .input(r)):
            return l == r
        case let (.delete(l), .delete(r)):
            return l == r
        case (.smoothDelete, .smoothDelete):
            return true
        case (.deselectAndUseAsInputting, .deselectAndUseAsInputting):
            return true
        case (.saveSelectedTextIfNeeded, .saveSelectedTextIfNeeded):
            return true
        case (.restoreSelectedTextIfNeeded, .restoreSelectedTextIfNeeded):
            return true
        case let (.moveCursor(l),.moveCursor(r)):
            return l == r
        case (.toggleTabBar, .toggleTabBar):
            return true
        case (.toggleShowMoveCursorView,.toggleShowMoveCursorView):
            return true
        case (.enter, .enter):
            return true
        case (.changeCharacterType, .changeCharacterType):
            return true
        case let (.changeCapsLockState(l),.changeCapsLockState(r)):
            return l == r
        case (.hideLearningMemory, .hideLearningMemory):
            return true
        case (.dismissKeyboard, .dismissKeyboard):
            return true
        case let (.moveTab(l), .moveTab(r)):
            return l == r
        case let (.openApp(l), .openApp(r)):
            return l == r
        #if DEBUG
        case (.DEBUG_DATA_INPUT, .DEBUG_DATA_INPUT):
            return true
        #endif
        default:
            return false
        }
    }

}

extension ActionType{
    static func makeFunctionInputActionSet(name: String, argumentCount: Int = 1) -> [ActionType] {
        /*
         sqrt()
         ↑.saveSelectedTextIfNeeded, .input("sqrt()"), .moveCursor(-1), .restoreSelectedTextIfNeeded
         のようにする。ただしこの返り値を利用する場合には.flatmap{$0}が必須。
         */
        return [
            .saveSelectedTextIfNeeded,
            .input("\(name)()"),
            .moveCursor(-1),
            .restoreSelectedTextIfNeeded
        ]
    }
}

//長押しor長フリックされた際の挙動のタイプ
enum LongPressActionType: Equatable{
    case `repeat`(ActionType)
    case doOnce(ActionType)

    static func == (lsb: LongPressActionType, rsb: LongPressActionType) -> Bool {
        switch (lsb, rsb){
        case let (.repeat(l),.repeat(r)):
            return l == r
        case let (.doOnce(l),.doOnce(r)):
            return l == r
        default:
            return false
        }
    }
}

extension CodableActionData{
    var actionType: ActionType {
        switch self{
        case let .input(value):
            return .input(value)
        case let .longInput(value):
            return .input(value)
        case .exchangeCharacter:
            return .changeCharacterType
        case let .delete(value):
            return .delete(value)
        case let .longDelete(value):
            return .delete(value)
        case .smoothDelete:
            return .smoothDelete
        case .complete:
            return .enter
        case let .moveCursor(value):
            return .moveCursor(value)
        case let .longMoveCursor(value):
            return .moveCursor(value)
        case let .moveTab(value):
            return .moveTab(value.tab)
        case .toggleCursorMovingView:
            return .toggleShowMoveCursorView
        case .toggleCapsLockState:
            switch VariableStates.shared.aAKeyState{
            case .normal:
                return .changeCapsLockState(state: .capslock)
            case .capslock:
                return .changeCapsLockState(state: .normal)
            }
        case .toggleTabBar:
            return .toggleTabBar
        case let .openApp(value):
            return .openApp(value)
        case .dismissKeyboard:
            return .dismissKeyboard
        }
    }

    var longpressActionType: LongPressActionType {
        switch self{
        case let .longInput(value):
            return .repeat(.input(value))
        case let .longDelete(value):
            return .repeat(.delete(value))
        case let .longMoveCursor(value):
            return .repeat(.moveCursor(value))
        default:
            return .doOnce(self.actionType)
        }
    }
}
